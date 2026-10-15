# Zero-Filled File Generator

A lightweight Bash utility for generating zero-filled text files for file-handling experiments, storage testing, and controlled lab demonstrations on Linux.

## Overview

`zero-filled_file_generator.sh` generates ordinary files containing zero (`0`) characters. It is intended for educational use and authorized testing in environments you own or have explicit permission to use.

**Important:** This tool does not create ZIP archives or ZIP bombs. It generates plain-text files containing zero characters.

## Features

- Written in Bash for Linux environments.
- Generates multiple zero-filled text files.
- Allows configuration of file counts and file sizes, depending on the script's validation settings.
- Uses terminal colors for clearer status messages.
- Includes authorization confirmation and safety warnings.
- Helps demonstrate file creation, storage usage, and file-system behavior.

## Requirements

- A Linux operating system.
- Bash.
- Standard utilities used by the script, such as `head`, `tr`, and `df`.
- Sufficient free disk space and permission to write to the selected directory.

## Installation

Clone the repository:

```bash
git clone https://github.com/meherazhosensiam/Zero-Filled-File-Generator.git
```

Enter the project directory:

```bash
cd Zero-Filled-File-Generator
```

Make the script executable:

```bash
chmod +x zero-filled_file_generator.sh
```

Run it:

```bash
./zero-filled_file_generator.sh
```

If the script in your repository has a different filename, substitute its actual name in these commands.

## Configuration

The script may use configurable safety limits such as:

```bash
readonly MAX_FILES=100
readonly MAX_FILE_BYTES=1048576
readonly MAX_TOTAL_BYTES=10485760
```

| Variable | Purpose |
|---|---|
| `MAX_FILES` | Maximum number of files allowed |
| `MAX_FILE_BYTES` | Maximum size allowed for an individual file, in bytes |
| `MAX_TOTAL_BYTES` | Maximum combined file size, in bytes |

The values above represent 100 files, 1 MiB per file, and 10 MiB combined. The script must explicitly validate user input against these variables for the limits to take effect.

## Safety and Responsible Use

This utility creates files on disk and can consume storage space. Before running it:

- Use a personal machine, disposable virtual machine, or isolated test environment.
- Verify the destination directory and available disk space.
- Start with small test values.
- Do not run experiments on shared systems without explicit authorization.
- Stop the experiment if it affects system performance or other users.
- Remove generated files when they are no longer needed.

Never use this utility to disrupt services, exhaust another system's storage, or interfere with systems without authorization.

## Disclaimer

This project is provided for educational purposes and controlled testing. You are responsible for how you use, configure, and distribute it.

Only run the tool on systems you own or have explicit permission to test. Unauthorized activity may violate applicable laws, policies, or terms of service.

The author does not authorize unlawful use of this software. This disclaimer does not grant permission to access or test third-party systems, waive legal obligations, or eliminate liability where applicable law provides otherwise.

## Limitations

- The output consists of plain-text files containing zero characters.
- The tool does not create compressed archives.
- Generated zero-filled content compresses efficiently, so file size before compression may differ significantly from archive size.
- Actual disk usage depends on the filesystem and system configuration.

## Repository

**GitHub:** https://github.com/meherazhosensiam/Zero-Filled-File-Generator

## Author

**Meheraz Hossen Siyam**

GitHub: [@meherazhosensiam](https://github.com/meherazhosensiam)

---

*Learn responsibly. Test with permission. Document your findings.*
