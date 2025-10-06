@echo off
setlocal enabledelayedexpansion

:: 设置颜色
color 0A
title JS文件提取与合并工具

:: 自动检测当前目录
set "current_dir=%~dp0"
if "%current_dir:~-1%"=="\" set "current_dir=%current_dir:~0,-1%"

:: 检查当前目录是否有questions文件夹
set "auto_detected=0"
if exist "%current_dir%\questions" (
    set "default_path=%current_dir%"
    set "auto_detected=1"
    echo 检测到当前目录存在questions文件夹: %current_dir%
    echo.
)

:: 获取输入路径
:input_path
set "source_path="
if defined auto_detected (
    set /p "source_path=请输入源文件夹路径[回车使用当前目录: %default_path%]: "
    if not defined source_path set "source_path=%default_path%"
) else (
    set /p "source_path=请输入源文件夹路径(包含questions目录): "
)

if not defined source_path goto input_path
if not exist "%source_path%\questions" (
    echo 错误: 路径下未找到questions文件夹!
    echo.
    set "auto_detected=0"
    goto input_path
)

:: 设置默认输出路径为当前目录下的output文件夹
set "default_output=%current_dir%\output"

:: 获取输出路径
:output_path
set "output_path="
set /p "output_path=请输入输出文件夹路径[回车使用默认: %default_output%]: "
if not defined output_path set "output_path=%default_output%"

:: 创建输出文件夹（如果不存在）
if not exist "%output_path%" (
    echo 创建输出文件夹: %output_path%
    mkdir "%output_path%"
)

:: 设置questions路径
set "questions_path=%source_path%\questions"
set "combined_js=%output_path%\combined.js"

echo.
echo 正在处理: %questions_path%
echo 输出到: %output_path%
echo.

:: 创建临时文件
set "temp_file=%temp%\js_list.txt"
del "%temp_file%" 2>nul >nul

:: 计数器
set /a file_count=0
set /a folder_count=0

:: 遍历所有子文件夹
for /d %%d in ("%questions_path%\*") do (
    set "folder=%%~nxd"
    set /a folder_count+=1
    set "js_found=0"
    
    :: 查找MP3文件获取题号
    set "t_num="
    if exist "%%d\media\" (
        pushd "%%d\media"
        for /f "delims=" %%a in ('dir /b /a-d *T*.mp3 2^>nul') do (
            set "audio_file=%%a"
            echo 在 !folder! 找到音频文件: %%a
            
            :: 从文件名提取题号
            set "fname=%%a"
            set "fname=!fname:T= T!"
            for /f "tokens=2 delims=T " %%t in ("!fname!") do (
                set "num=%%t"
                for /f "delims=0123456789" %%x in ("!num!") do set "t_num=!num:%%x=!"
            )
        )
        popd
    )
    
    :: 查找JS文件 - 首先在net文件夹中查找
    set "js_file="
    if exist "%%d\net\" (
        pushd "%%d\net"
        for /f "delims=" %%j in ('dir /b /a-d *.js 2^>nul') do (
            if not defined js_file (
                set "js_file=%%j"
                set "js_path=%%d\net\!js_file!"
                set "js_found=1"
                echo 在 !folder!\net 找到JS文件: !js_file!
            )
        )
        popd
    )
    
    :: 如果在net文件夹没找到JS文件，则在上级目录查找
    if !js_found! equ 0 (
        pushd "%%d"
        for /f "delims=" %%j in ('dir /b /a-d *.js 2^>nul') do (
            if not defined js_file (
                set "js_file=%%j"
                set "js_path=%%d\!js_file!"
                set "js_found=1"
                echo 在 !folder! 根目录找到JS文件: !js_file!
            )
        )
        popd
    )
    
    :: 处理JS文件
    if defined js_file (
        set /a file_count+=1
        
        :: 格式化为两位数题号
        if defined t_num (
            set "padded_num=00!t_num!"
            set "padded_num=!padded_num:~-2!"
        ) else (
            set "padded_num=XX"
        )
        
        :: 复制JS文件到输出文件夹
        set "new_name=T!padded_num!_!folder!_!js_file!"
        copy "!js_path!" "%output_path%\!new_name!" >nul
        
        :: 记录文件信息用于合并
        echo !padded_num! "!js_path!" >> "%temp_file%"
        
        echo 已复制: !new_name!
    )
)

:: 检查是否找到文件
if %file_count% equ 0 (
    echo.
    echo 错误: 未找到任何JS文件!
    pause
    exit /b 1
)

echo.
echo 共处理 %folder_count% 个文件夹, 提取 %file_count% 个JS文件

:: 合并JS文件
if exist "%temp_file%" (
    echo.
    echo 正在合并JS文件到: %combined_js%
    del "%combined_js%" 2>nul >nul
    
    :: 按题号排序
    sort "%temp_file%" > "%temp_file%.sorted"
    
    for /f "usebackq tokens=1*" %%a in ("%temp_file%.sorted") do (
        set "js_path=%%b"
        set "js_path=!js_path:"=!"
        type "!js_path!" >> "%combined_js%"
        echo. >> "%combined_js%"
    )
    
    del "%temp_file%" "%temp_file%.sorted" 2>nul >nul
    echo 合并完成! 输出文件: %combined_js%
)

echo.
echo 操作全部完成!
echo 按任意键退出...
pause >nul
endlocal