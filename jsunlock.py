import re
import sys
import tkinter as tk
from tkinter import font

class ExamAnalyzer:
    def __init__(self):
        self.content = ""
        self.answers = []
        
    def read_file(self):
        """Read the JavaScript file containing exam data"""
        file_options = ['combined.js', 'page1.js']
        
        for filename in file_options:
            try:
                with open(filename, 'r', encoding='utf-8') as file:
                    self.content = file.read()
                    print(f"成功读取 {filename} 文件")
                    return True
            except FileNotFoundError:
                print(f"{filename} 文件不存在，尝试下一个文件...")
            except Exception as e:
                print(f"读取 {filename} 时发生错误: {str(e)}")
        
        print("错误：未找到可用的数据文件")
        return False
    
    def extract_answers(self):
        """Extract answer content from the JavaScript file"""
        try:
            # Match content between "answer_text" and "knowledge"
            pattern = r'"answer_text"(.*?)"knowledge"'
            matches = re.findall(pattern, self.content, re.DOTALL)
            
            if not matches:
                print("未找到答案内容，请检查文件格式")
                return False
            
            self.answers = [match.strip() for match in matches]
            return True
            
        except Exception as e:
            print(f"提取答案时发生错误: {str(e)}")
            return False
    
    def parse_answer_options(self):
        """Parse the answer options from extracted content"""
        outputs = []
        
        for answer in self.answers:
            # Find the first occurrence of A, B, C, or D
            option_match = re.search(r'[A-D]', answer)
            if not option_match:
                continue
                
            option = option_match.group()
            
            # Find the content corresponding to this option
            pattern = rf'"id":"{option}"(.*?)"content":"(.*?)"'
            content_match = re.search(pattern, answer)
            
            if content_match:
                outputs.append(content_match.group(2))
        
        return outputs


class AnswerDisplay:
    def __init__(self):
        self.window = tk.Tk()
        self.window.title("天学网分析")
        self.window.attributes("-topmost", True)
        
        # Create custom font
        self.custom_font = font.Font(family="宋体", size=12)
        
        # Create text widget
        self.text_widget = tk.Text(self.window, font=self.custom_font)
        self.text_widget.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
    
    def display_content(self, content_list):
        """Display content in the text widget"""
        for index, content in enumerate(content_list, 1):
            display_text = f"{index}. {content}"
            self.text_widget.insert(tk.END, display_text + "\n\n")
    
    def run(self):
        """Start the GUI main loop"""
        self.window.mainloop()


def main():
    # Initialize analyzer
    analyzer = ExamAnalyzer()
    
    # Read file
    if not analyzer.read_file():
        sys.exit(1)
    
    # Extract answers
    if not analyzer.extract_answers():
        sys.exit(1)
    
    # Parse answer options
    answer_contents = analyzer.parse_answer_options()
    
    if not answer_contents:
        print("未找到有效的答案选项")
        sys.exit(1)
    
    # Display results in GUI
    display = AnswerDisplay()
    display.display_content(answer_contents)
    display.run()


if __name__ == "__main__":
    main()