@echo off
setlocal enabledelayedexpansion

:: ������ɫ
color 0A
title JS�ļ���ȡ��ϲ�����

:: �Զ���⵱ǰĿ¼
set "current_dir=%~dp0"
if "%current_dir:~-1%"=="\" set "current_dir=%current_dir:~0,-1%"

:: ��鵱ǰĿ¼�Ƿ���questions�ļ���
set "auto_detected=0"
if exist "%current_dir%\questions" (
    set "default_path=%current_dir%"
    set "auto_detected=1"
    echo ��⵽��ǰĿ¼����questions�ļ���: %current_dir%
    echo.
)

:: ��ȡ����·��
:input_path
set "source_path="
if defined auto_detected (
    set /p "source_path=������Դ�ļ���·��[�س�ʹ�õ�ǰĿ¼: %default_path%]: "
    if not defined source_path set "source_path=%default_path%"
) else (
    set /p "source_path=������Դ�ļ���·��(����questionsĿ¼): "
)

if not defined source_path goto input_path
if not exist "%source_path%\questions" (
    echo ����: ·����δ�ҵ�questions�ļ���!
    echo.
    set "auto_detected=0"
    goto input_path
)

:: ����Ĭ�����·��Ϊ��ǰĿ¼�µ�output�ļ���
set "default_output=%current_dir%\output"

:: ��ȡ���·��
:output_path
set "output_path="
set /p "output_path=����������ļ���·��[�س�ʹ��Ĭ��: %default_output%]: "
if not defined output_path set "output_path=%default_output%"

:: ��������ļ��У���������ڣ�
if not exist "%output_path%" (
    echo ��������ļ���: %output_path%
    mkdir "%output_path%"
)

:: ����questions·��
set "questions_path=%source_path%\questions"
set "combined_js=%output_path%\combined.js"

echo.
echo ���ڴ���: %questions_path%
echo �����: %output_path%
echo.

:: ������ʱ�ļ�
set "temp_file=%temp%\js_list.txt"
del "%temp_file%" 2>nul >nul

:: ������
set /a file_count=0
set /a folder_count=0

:: �����������ļ���
for /d %%d in ("%questions_path%\*") do (
    set "folder=%%~nxd"
    set /a folder_count+=1
    set "js_found=0"
    
    :: ����MP3�ļ���ȡ���
    set "t_num="
    if exist "%%d\media\" (
        pushd "%%d\media"
        for /f "delims=" %%a in ('dir /b /a-d *T*.mp3 2^>nul') do (
            set "audio_file=%%a"
            echo �� !folder! �ҵ���Ƶ�ļ�: %%a
            
            :: ���ļ�����ȡ���
            set "fname=%%a"
            set "fname=!fname:T= T!"
            for /f "tokens=2 delims=T " %%t in ("!fname!") do (
                set "num=%%t"
                for /f "delims=0123456789" %%x in ("!num!") do set "t_num=!num:%%x=!"
            )
        )
        popd
    )
    
    :: ����JS�ļ� - ������net�ļ����в���
    set "js_file="
    if exist "%%d\net\" (
        pushd "%%d\net"
        for /f "delims=" %%j in ('dir /b /a-d *.js 2^>nul') do (
            if not defined js_file (
                set "js_file=%%j"
                set "js_path=%%d\net\!js_file!"
                set "js_found=1"
                echo �� !folder!\net �ҵ�JS�ļ�: !js_file!
            )
        )
        popd
    )
    
    :: �����net�ļ���û�ҵ�JS�ļ��������ϼ�Ŀ¼����
    if !js_found! equ 0 (
        pushd "%%d"
        for /f "delims=" %%j in ('dir /b /a-d *.js 2^>nul') do (
            if not defined js_file (
                set "js_file=%%j"
                set "js_path=%%d\!js_file!"
                set "js_found=1"
                echo �� !folder! ��Ŀ¼�ҵ�JS�ļ�: !js_file!
            )
        )
        popd
    )
    
    :: ����JS�ļ�
    if defined js_file (
        set /a file_count+=1
        
        :: ��ʽ��Ϊ��λ�����
        if defined t_num (
            set "padded_num=00!t_num!"
            set "padded_num=!padded_num:~-2!"
        ) else (
            set "padded_num=XX"
        )
        
        :: ����JS�ļ�������ļ���
        set "new_name=T!padded_num!_!folder!_!js_file!"
        copy "!js_path!" "%output_path%\!new_name!" >nul
        
        :: ��¼�ļ���Ϣ���ںϲ�
        echo !padded_num! "!js_path!" >> "%temp_file%"
        
        echo �Ѹ���: !new_name!
    )
)

:: ����Ƿ��ҵ��ļ�
if %file_count% equ 0 (
    echo.
    echo ����: δ�ҵ��κ�JS�ļ�!
    pause
    exit /b 1
)

echo.
echo ������ %folder_count% ���ļ���, ��ȡ %file_count% ��JS�ļ�

:: �ϲ�JS�ļ�
if exist "%temp_file%" (
    echo.
    echo ���ںϲ�JS�ļ���: %combined_js%
    del "%combined_js%" 2>nul >nul
    
    :: ���������
    sort "%temp_file%" > "%temp_file%.sorted"
    
    for /f "usebackq tokens=1*" %%a in ("%temp_file%.sorted") do (
        set "js_path=%%b"
        set "js_path=!js_path:"=!"
        type "!js_path!" >> "%combined_js%"
        echo. >> "%combined_js%"
    )
    
    del "%temp_file%" "%temp_file%.sorted" 2>nul >nul
    echo �ϲ����! ����ļ�: %combined_js%
)

echo.
echo ����ȫ�����!
echo ��������˳�...
pause >nul
endlocal