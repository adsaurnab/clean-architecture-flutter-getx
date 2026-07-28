import os

# ====== CONFIGURATION ======

# Set to something like ".py", ".txt"
# Set to None to include ALL files
# EXTENSION_FILTER = ".py"
EXTENSION_FILTER = None

# Include subfolders?
INCLUDE_SUBFOLDERS = True

# Output file name (created in same folder)
OUTPUT_FILE_NAME = "combined_output.txt"

# Files to exclude (exact file names)
EXCLUDE_FILES = [
    "combined_output.txt",
    "new_html_data.txt",
    "combine_files.py",
    '.gitattributes',
    'firebase_options.dart',
    'portfolio.json',
    '.gitignore',
    'gradle.properties',
    'foldertree20260429162943.txt',
    'generate_tree.py',
    'gradlew',
    'gradlew.bat',
    'local.properties',
    'notification_logger_app_android.iml',
    'face_painters_backup.zip',
    'animated_mood_face.dart.backup',
    'firebase_options.dart',
]

# Folders to exclude (folder names only, not full paths)
EXCLUDE_FOLDERS = [
    "__pycache__",
    ".git",
    "venv",
    '.gradle',
    '.kotlin',
    'gradle',
    'app/src/debug/',
    'app/src/profile/',
    'app/src/main/res/',
    "gen",
    "l10n",
    "core/cubit/",
    "core/error/",
    "core/error/",
]

# File patterns to exclude
EXCLUDE_END_PATTERNS = [
    ".freezed.dart",
    ".freezed.dart",
    ".g.dart",
    ".gen.dart",
]


EXCLUDE_START_PATTERNS = [
    "combined_output",
]

# ============================


def should_include_file(filename):
    if EXTENSION_FILTER is None:
        return True
    return filename.lower().endswith(EXTENSION_FILTER.lower())


def collect_files(base_folder):
    file_paths = []

    exclude_folders = set(os.path.normpath(p) for p in EXCLUDE_FOLDERS)

    if INCLUDE_SUBFOLDERS:
        for root, dirs, files in os.walk(base_folder):

            # compute relative path of current root
            rel_root = os.path.relpath(root, base_folder)
            rel_root = "" if rel_root == "." else os.path.normpath(rel_root)

            # filter dirs based on full relative path
            dirs[:] = [
                d for d in dirs
                if os.path.normpath(os.path.join(rel_root, d)) not in exclude_folders
            ]

            for file in files:
                if file in EXCLUDE_FILES:
                    continue

                # exclude files ending with patterns
                if any(file.endswith(pattern) for pattern in EXCLUDE_END_PATTERNS):
                    continue

                # exclude files starting with patterns
                if any(file.startswith(pattern) for pattern in EXCLUDE_START_PATTERNS):
                    continue

                if should_include_file(file):
                    file_paths.append(os.path.join(root, file))

    else:
        for file in os.listdir(base_folder):
            full_path = os.path.join(base_folder, file)

            if not os.path.isfile(full_path):
                continue

            if file in EXCLUDE_FILES:
                continue

            if should_include_file(file):
                file_paths.append(full_path)

    return file_paths


def combine_files(file_list, output_path):
    with open(output_path, "w", encoding="utf-8") as outfile:
        for file_path in sorted(file_list):
            try:
                with open(file_path, "r", encoding="utf-8") as infile:
                    outfile.write("\n" + "=" * 80 + "\n")
                    outfile.write(f"FILE: {os.path.relpath(file_path)}\n")
                    outfile.write("=" * 80 + "\n\n")
                    outfile.write(infile.read())
                    outfile.write("\n")
            except Exception as e:
                print(f"Skipping {file_path} due to error: {e}")


def main():
    base_folder = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(base_folder, OUTPUT_FILE_NAME)

    files = collect_files(base_folder)

    print(f"Found {len(files)} file(s) to combine.")
    combine_files(files, output_path)
    print(f"Combined file created at: {output_path}")


if __name__ == "__main__":
    main()