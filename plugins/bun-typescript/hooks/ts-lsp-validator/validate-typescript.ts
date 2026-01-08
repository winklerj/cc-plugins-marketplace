#!/usr/bin/env bun
/**
 * TypeScript LSP Validation Hook
 * Uses TypeScript Language Server for comprehensive type checking
 *
 * EXIT CODES:
 *   0 - Success (no errors, warnings are displayed but don't block)
 *   1 - General error (missing dependencies, etc.)
 *   2 - TypeScript errors found (blocking - used only if BLOCK_ON_ERRORS=true)
 */

import { existsSync } from 'fs';
import { relative, basename, dirname, join } from 'path';

// ANSI color codes for output
const colors = {
	red: '\x1b[0;31m',
	green: '\x1b[0;32m',
	yellow: '\x1b[0;33m',
	blue: '\x1b[0;34m',
	cyan: '\x1b[0;36m',
	magenta: '\x1b[0;35m',
	reset: '\x1b[0m',
};

// Configuration from environment variables
const config = {
	blockOnErrors: process.env.TS_LSP_BLOCK_ON_ERRORS === 'true',
	showWarnings: process.env.TS_LSP_SHOW_WARNINGS !== 'false',
	debug: process.env.TS_LSP_DEBUG === 'true',
	timeout: parseInt(process.env.TS_LSP_TIMEOUT ?? '10000', 10),
};

// Logging utilities
const log = {
	info: (msg: string) => console.error(`${colors.blue}[INFO]${colors.reset} ${msg}`),
	error: (msg: string) => console.error(`${colors.red}[ERROR]${colors.reset} ${msg}`),
	success: (msg: string) => console.error(`${colors.green}[OK]${colors.reset} ${msg}`),
	warning: (msg: string) => console.error(`${colors.yellow}[WARN]${colors.reset} ${msg}`),
	debug: (msg: string) => {
		if (config.debug) {
			console.error(`${colors.cyan}[DEBUG]${colors.reset} ${msg}`);
		}
	},
};

/**
 * Get project root from environment variable
 */
function getProjectRoot(): string {
	return process.env.CLAUDE_PROJECT_DIR ?? process.cwd();
}

/**
 * Find the appropriate tsconfig.json for a given file
 */
function findTsConfig(filePath: string): string | null {
	const projectRoot = getProjectRoot();
	let currentDir = dirname(filePath);

	// Walk up the directory tree looking for tsconfig.json
	while (currentDir.startsWith(projectRoot)) {
		const tsConfigPath = join(currentDir, 'tsconfig.json');
		if (existsSync(tsConfigPath)) {
			return tsConfigPath;
		}

		const parentDir = dirname(currentDir);
		if (parentDir === currentDir) break;
		currentDir = parentDir;
	}

	// Fallback to project root tsconfig.json
	const rootTsConfig = join(projectRoot, 'tsconfig.json');
	if (existsSync(rootTsConfig)) {
		return rootTsConfig;
	}

	return null;
}

/**
 * Parse Claude Code hook input from stdin
 */
async function parseHookInput(): Promise<{ filePath: string } | null> {
	const stdin = await Bun.stdin.text();

	if (stdin.trim().length === 0) {
		log.warning('No JSON input provided');
		return null;
	}

	try {
		const input = JSON.parse(stdin);
		const filePath = input.tool_input?.file_path ??
                     input.tool_input?.path ??
                     input.tool_input?.notebook_path;

		if (filePath === undefined || filePath === null) {
			log.debug('No file path found in input');
			return null;
		}

		return { filePath };
	} catch (error) {
		log.error(`Failed to parse JSON input: ${error}`);
		return null;
	}
}

/**
 * Check if file is a TypeScript file
 */
function isTypeScriptFile(filePath: string): boolean {
	return /\.(ts|tsx)$/.test(filePath);
}

/**
 * Use TypeScript API directly for comprehensive type checking
 */
async function runTypeScriptAPICheck(filePath: string, tsConfigPath: string): Promise<{
  errors: Array<{ line: number; column: number; message: string; code: number }>;
  warnings: Array<{ line: number; column: number; message: string; code: number }>;
}> {
	const ts = await import('typescript');

	// Read and parse tsconfig
	const configFile = ts.readConfigFile(tsConfigPath, ts.sys.readFile);
	if (configFile.error !== undefined) {
		const errorMessage = typeof configFile.error.messageText === 'string'
			? configFile.error.messageText
			: ts.flattenDiagnosticMessageText(configFile.error.messageText, '\n');
		throw new Error(`Failed to read tsconfig: ${errorMessage}`);
	}

	const parsedConfig = ts.parseJsonConfigFileContent(
		configFile.config,
		ts.sys,
		dirname(tsConfigPath)
	);

	// Create a program with only the target file
	const program = ts.createProgram([filePath], parsedConfig.options);

	// Get diagnostics for the file
	const sourceFile = program.getSourceFile(filePath);
	if (sourceFile === null || sourceFile === undefined) {
		throw new Error(`Could not load source file: ${filePath}`);
	}

	const allDiagnostics = [
		...program.getSemanticDiagnostics(sourceFile),
		...program.getSyntacticDiagnostics(sourceFile),
	];

	const errors: Array<{ line: number; column: number; message: string; code: number }> = [];
	const warnings: Array<{ line: number; column: number; message: string; code: number }> = [];

	for (const diagnostic of allDiagnostics) {
		if (diagnostic.file === null || diagnostic.file === undefined || diagnostic.file.fileName !== filePath) {
			continue;
		}

		const { line, character } = diagnostic.file.getLineAndCharacterOfPosition(
			diagnostic.start ?? 0
		);

		const message = ts.flattenDiagnosticMessageText(diagnostic.messageText, '\n');
		const code = diagnostic.code;

		const item = {
			line: line + 1,
			column: character + 1,
			message,
			code,
		};

		// TypeScript uses category to determine error vs warning
		if (diagnostic.category === ts.DiagnosticCategory.Error) {
			errors.push(item);
		} else if (diagnostic.category === ts.DiagnosticCategory.Warning) {
			warnings.push(item);
		} else {
			// Treat suggestions and messages like warnings
			warnings.push(item);
		}
	}

	return { errors, warnings };
}

/**
 * Format and display validation results
 */
function displayResults(
	filePath: string,
	errors: Array<{ line: number; column: number; message: string; code: number }>,
	warnings: Array<{ line: number; column: number; message: string; code: number }>
): void {
	const projectRoot = getProjectRoot();
	const relativePath = relative(projectRoot, filePath);

	console.error('');
	console.error(`${colors.blue}${'═'.repeat(60)}${colors.reset}`);
	console.error(`${colors.blue}TypeScript LSP Validation Results${colors.reset}`);
	console.error(`${colors.blue}${'═'.repeat(60)}${colors.reset}`);
	console.error(`File: ${colors.cyan}${relativePath}${colors.reset}`);
	console.error('');

	if (errors.length === 0 && warnings.length === 0) {
		console.error(`${colors.green}No TypeScript errors or warnings found!${colors.reset}`);
		console.error('');
		return;
	}

	// Display errors
	if (errors.length > 0) {
		console.error(`${colors.red}Errors (${errors.length}):${colors.reset}`);
		for (const error of errors) {
			console.error(
				`  ${colors.red}X${colors.reset} ${colors.yellow}Line ${error.line}:${error.column}${colors.reset} ` +
        `[TS${error.code}] ${error.message}`
			);
		}
		console.error('');
	}

	// Display warnings
	if (config.showWarnings && warnings.length > 0) {
		console.error(`${colors.yellow}Warnings (${warnings.length}):${colors.reset}`);
		for (const warning of warnings) {
			console.error(
				`  ${colors.yellow}!${colors.reset} ${colors.yellow}Line ${warning.line}:${warning.column}${colors.reset} ` +
        `[TS${warning.code}] ${warning.message}`
			);
		}
		console.error('');
	}
}

/**
 * Main execution
 */
async function main(): Promise<void> {
	// Display header
	console.error('');
	console.error(`${colors.magenta}TypeScript LSP Validator${colors.reset}`);
	console.error(`${colors.blue}${'─'.repeat(60)}${colors.reset}`);

	// Parse hook input
	const hookInput = await parseHookInput();
	if (hookInput === null) {
		log.info('No file to validate');
		process.exit(0);
	}

	const { filePath } = hookInput;

	// Validate file exists
	if (!existsSync(filePath)) {
		log.info(`File does not exist: ${filePath}`);
		process.exit(0);
	}

	// Check if it's a TypeScript file
	if (!isTypeScriptFile(filePath)) {
		log.debug(`Skipping non-TypeScript file: ${basename(filePath)}`);
		console.error(`${colors.yellow}Skipped - not a TypeScript file${colors.reset}`);
		console.error('');
		process.exit(0);
	}

	// Find tsconfig
	const tsConfigPath = findTsConfig(filePath);
	if (tsConfigPath === null) {
		log.warning('No tsconfig.json found - skipping validation');
		console.error('');
		process.exit(0);
	}

	// Run TypeScript validation using API
	log.info('Running TypeScript validation...');

	try {
		const { errors, warnings } = await runTypeScriptAPICheck(filePath, tsConfigPath);

		// Display results
		displayResults(filePath, errors, warnings);

		// Determine exit code
		if (errors.length > 0) {
			if (config.blockOnErrors) {
				console.error(`${colors.red}Validation failed - TypeScript errors must be fixed!${colors.reset}`);
				console.error('');
				process.exit(2); // Blocking error
			} else {
				console.error(`${colors.yellow}TypeScript errors found but not blocking${colors.reset}`);
				console.error(`${colors.yellow}   Set TS_LSP_BLOCK_ON_ERRORS=true to block on errors${colors.reset}`);
				console.error('');
				process.exit(0); // Non-blocking
			}
		} else if (warnings.length > 0) {
			console.error(`${colors.green}Validation passed with warnings${colors.reset}`);
			console.error('');
			process.exit(0);
		} else {
			console.error(`${colors.green}Validation passed${colors.reset}`);
			console.error('');
			process.exit(0);
		}
	} catch (error) {
		log.error(`Validation failed: ${error}`);
		if (config.debug) {
			console.error(error);
		}
		process.exit(1);
	}
}

// Run main with error handling
main().catch((error) => {
	log.error(`Fatal error: ${error}`);
	process.exit(1);
});
