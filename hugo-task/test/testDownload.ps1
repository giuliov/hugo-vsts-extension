$env:INPUT_HUGOVERSION = "0.68.1"
$env:INPUT_HUGOVERSION = "latest"
$env:INPUT_EXTENDEDVERSION = 'true'

$env:TASK_TEST_TRACE=1
$env:Agent_ToolsDirectory='C:\src\github.com\giuliov\hugo-azdo-extension\hugo-task\test\TOOLS'
$env:Agent_TempDirectory='C:\src\github.com\giuliov\hugo-azdo-extension\hugo-task\test\TEMP'
$env:Agent_Version='2.115.0'
node ..\dist\src\HugoTask.js
