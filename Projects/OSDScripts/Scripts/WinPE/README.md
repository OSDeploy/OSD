Scripts in this directory should be run in WinPE
A good way to ensure you are in WinPE is to use the following condition

if ($env:SystemDrive -eq 'X:') {
    # Put your code in here
}