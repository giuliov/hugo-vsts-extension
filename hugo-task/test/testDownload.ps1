$env:INPUT_HUGOVERSION = "0.88.0"
$env:INPUT_EXTENDEDVERSION = 'false'

$env:TASK_TEST_TRACE=1
$env:Agent_ToolsDirectory='C:\src\github.com\giuliov\hugo-azdo-extension\hugo-task\test\TOOLS'
$env:Agent_TempDirectory='C:\src\github.com\giuliov\hugo-azdo-extension\hugo-task\test\TEMP'
$env:Agent_Version='2.115.0'
node ..\dist\src\HugoTask.js
