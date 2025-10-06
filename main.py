import xml.etree.ElementTree as ET
import re

def extract_cdata_from_xml(xml_file, output_file):
    """
    从XML文件中提取所有answer标签内的CDATA内容
    
    参数:
        xml_file (str): 输入XML文件路径
        output_file (str): 输出TXT文件路径
    """
    try:
        # 解析XML文件
        tree = ET.parse(xml_file)
        root = tree.getroot()
        
        # 提取所有answer标签的CDATA内容
        cdata_contents = []
        
        # 方法1: 使用ElementTree查找所有answer元素
        for answer in root.findall('.//answer'):
            if answer.text:  # 检查是否有CDATA内容
                cdata_contents.append(answer.text.strip())
        
        # 方法2: 如果方法1不奏效，可以使用正则表达式从原始XML中提取
        if not cdata_contents:
            print("使用方法2: 正则表达式提取")
            with open(xml_file, 'r', encoding='utf-8') as f:
                xml_content = f.read()
            
            # 使用正则表达式匹配CDATA内容
            cdata_pattern = r'<!\[CDATA\[(.*?)\]\]>'
            cdata_contents = re.findall(cdata_pattern, xml_content)
        
        # 将提取的内容写入输出文件
        with open(output_file, 'w', encoding='utf-8') as f:
            for content in cdata_contents:
                f.write(content + '\n')
        
        print(f"成功提取 {len(cdata_contents)} 个CDATA内容到 {output_file}")
        
        # 打印前几个提取的内容作为示例
        if cdata_contents:
            print("前5个提取的内容:")
            for i, content in enumerate(cdata_contents[:5]):
                print(f"{i+1}: {content}")
    
    except ET.ParseError as e:
        print(f"XML解析错误: {e}")
        # 如果XML解析失败，尝试使用正则表达式方法
        print("尝试使用正则表达式方法提取...")
        extract_with_regex(xml_file, output_file)
    except FileNotFoundError:
        print(f"错误: 文件 {xml_file} 未找到")
    except Exception as e:
        print(f"错误: {e}")

def extract_with_regex(xml_file, output_file):
    """
    使用正则表达式从XML文件中提取CDATA内容
    """
    try:
        with open(xml_file, 'r', encoding='utf-8') as f:
            xml_content = f.read()
        
        # 匹配answer标签内的CDATA内容
        pattern = r'<answer[^>]*><!\[CDATA\[(.*?)\]\]></answer>'
        cdata_contents = re.findall(pattern, xml_content)
        
        # 将提取的内容写入输出文件
        with open(output_file, 'w', encoding='utf-8') as f:
            for content in cdata_contents:
                f.write(content + '\n')
        
        print(f"使用正则表达式成功提取 {len(cdata_contents)} 个CDATA内容到 {output_file}")
        
        # 打印前几个提取的内容作为示例
        if cdata_contents:
            print("前5个提取的内容:")
            for i, content in enumerate(cdata_contents[:5]):
                print(f"{i+1}: {content}")
    
    except Exception as e:
        print(f"正则表达式提取错误: {e}")

def extract_specific_lines(xml_file, output_file, line_numbers):
    """
    提取指定行号的内容（保留原功能）
    
    参数:
        xml_file (str): 输入XML文件路径
        output_file (str): 输出TXT文件路径
        line_numbers (list): 要提取的行号列表
    """
    try:
        with open(xml_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        selected_lines = []
        for line_num in line_numbers:
            if 1 <= line_num <= len(lines):
                selected_lines.append(f"第{line_num}行: {lines[line_num-1].strip()}")
            else:
                print(f"警告: 行号 {line_num} 超出文件范围")
        
        with open(output_file, 'w', encoding='utf-8') as f:
            for line in selected_lines:
                f.write(line + '\n')
        
        print(f"成功提取指定行号内容到 {output_file}")
    
    except Exception as e:
        print(f"提取指定行号时出错: {e}")

# 主程序
if __name__ == "__main__":
    # 文件路径
    xml_file = "correctAnswer.xml"  # 输入XML文件，请根据实际修改
    output_cdata = "cdata_output.txt"  # CDATA内容输出文件
    output_lines = "lines_output.txt"  # 指定行号内容输出文件
    
    # 提取所有CDATA内容
    print("正在提取CDATA内容...")
    extract_cdata_from_xml(xml_file, output_cdata)
    
    print("\n" + "="*50 + "\n")
    
    # 提取数列对应的行号内容（保留原功能）
    line_numbers = [7, 13, 19, 25, 31]
    print(f"正在提取指定行号 {line_numbers} 的内容...")
    extract_specific_lines(xml_file, output_lines, line_numbers)