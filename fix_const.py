import os
import subprocess
import re

def run_analyze():
    print("Running flutter analyze...")
    result = subprocess.run(["flutter", "analyze"], capture_output=True, text=True)
    return result.stdout

def fix_errors(output):
    # Matches lines like:
    #  error • Arguments of a constant creation must be constant expressions • lib\screens\home_screen.dart:42:25 • const_with_non_constant_argument
    #  error • Invalid constant value • lib\widgets\custom_button.dart:12:30 • invalid_constant
    
    lines = output.split('\n')
    fixes_made = 0
    
    for line in lines:
        if 'error •' in line and ('const' in line or 'Arguments of a constant' in line or 'non_constant' in line):
            parts = line.split('•')
            if len(parts) >= 3:
                file_info = parts[2].strip()
                # file_info is like lib\screens\home_screen.dart:42:25
                file_parts = file_info.split(':')
                if len(file_parts) == 3:
                    filepath = file_parts[0]
                    line_num = int(file_parts[1]) - 1 # 0-indexed
                    
                    if os.path.exists(filepath):
                        with open(filepath, 'r', encoding='utf-8') as f:
                            content = f.readlines()
                            
                        # Extremely naive fix: just remove 'const ' from the line
                        original_line = content[line_num]
                        if 'const ' in original_line:
                            content[line_num] = original_line.replace('const ', '')
                            with open(filepath, 'w', encoding='utf-8') as f:
                                f.writelines(content)
                            fixes_made += 1
                            print(f"Fixed const in {filepath}:{line_num+1}")
    return fixes_made

def main():
    while True:
        output = run_analyze()
        fixes = fix_errors(output)
        if fixes == 0:
            print("No more const errors found!")
            break
        print(f"Made {fixes} fixes. Re-analyzing...")

if __name__ == '__main__':
    main()
