#using assembly "System.Windows.Forms.dll"
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$Form = New-Object System.Windows.Forms.Form

$Form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font;
$Form.ClientSize = New-Object System.Drawing.Size(1100, 600);
$Form.StartPosition ="CenterScreen"
$Form.Name = "Formwifi";
$Form.Text = "WiFi RVR/360度自动测试脚本";

$btnedit = New-Object Windows.Forms.Button
$btnedit.text = "编辑配置"
$btnedit.Location = New-Object Drawing.Point(40, 5)
$btnedit.add_click({ btneditClick })
$Form.controls.add($btnedit)

$button = New-Object Windows.Forms.Button
$button.text ="开始测试"
$button.Location = New-Object Drawing.Point(40, 40)
$button.Size = New-Object System.Drawing.Size(80, 40)
$button.add_click({btnStartClick})
$Form.controls.add($button)

$button1 = New-Object Windows.Forms.Button
$button1.text ="强制停止"
$button1.Location = New-Object Drawing.Point(130, 40)
$button1.Size = New-Object System.Drawing.Size(80, 40)
$button1.add_click({btnStopClick})
$Form.controls.add($button1)

$labelzp = new-object System.Windows.Forms.Label
$labelzp.text = "手动控制转盘："
$labelzp.Location = New-Object Drawing.Point(750, 30)
$labelzp.Size = New-Object Drawing.Point(170, 50)
$labelzp.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 12, [System.Drawing.FontStyle]::Bold)
#$labeltips.WordWrap = $false
$Form.controls.add($labelzp)

$btnZPgo = new-object System.Windows.Forms.Button
$btnZPgo.text = "转盘前进："
$btnZPgo.Location = New-Object Drawing.Point(750, 80)
$btnZPgo.Size = New-Object Drawing.Point(100, 50)
$btnZPgo.add_click({ btnZPgoClick })
$Form.controls.add($btnZPgo)

$textBoxgo = New-Object System.Windows.Forms.TextBox
$textBoxgo.Location = New-Object System.Drawing.Point(860, 90)
$textBoxgo.Size = New-Object System.Drawing.Size(60, 100)
$textBoxgo.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 14, [System.Drawing.FontStyle]::Bold)
$textBoxgo.Text = "30"
$form.Controls.Add($textBoxgo)

$labelJDtips1 = new-object System.Windows.Forms.Label
$labelJDtips1.text = "度"
$labelJDtips1.Location = New-Object Drawing.Point(930, 90)
$labelJDtips1.Size = New-Object Drawing.Point(40, 60)
$labelJDtips1.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 14, [System.Drawing.FontStyle]::Bold)
$Form.controls.add($labelJDtips1)

$labelJDtips3 = new-object System.Windows.Forms.Label
$labelJDtips3.text = "注：只支持1 5 10 15 30 60 90 360"
$labelJDtips3.Location = New-Object Drawing.Point(920, 30)
$labelJDtips3.Size = New-Object Drawing.Point(160, 60)
$Form.controls.add($labelJDtips3)

$btnZPback = new-object System.Windows.Forms.Button
$btnZPback.text = "转盘后退："
$btnZPback.Location = New-Object Drawing.Point(750, 160)
$btnZPback.Size = New-Object Drawing.Point(100, 50)
$btnZPback.add_click({ btnZPbackClick })
$Form.controls.add($btnZPback)

$textBoxback = New-Object System.Windows.Forms.TextBox
$textBoxback.Location = New-Object System.Drawing.Point(860, 170)
$textBoxback.Size = New-Object System.Drawing.Size(60, 100)
$textBoxback.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 14, [System.Drawing.FontStyle]::Bold)
$textBoxback.Text = "30"
$form.Controls.Add($textBoxback)

$labelJDtips2 = new-object System.Windows.Forms.Label
$labelJDtips2.text = "度"
$labelJDtips2.Location = New-Object Drawing.Point(930,170)
$labelJDtips2.Size = New-Object Drawing.Point(60,80)
$labelJDtips2.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 14, [System.Drawing.FontStyle]::Bold)
$Form.controls.add($labelJDtips2)

$button2 = New-Object Windows.Forms.Button
$button2.text = "设置衰减"
$button2.Location = New-Object Drawing.Point(750, 280)
$button2.Size = New-Object System.Drawing.Size(80, 40)
#$button2.DialogResult = [System.Windows.Forms.DialogResult]::OK
$button2.add_click({ btnATTClick })
$Form.controls.add($button2)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(840, 280)
$textBox.Size = New-Object System.Drawing.Size(50, 20)
$textBox.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 14, [System.Drawing.FontStyle]::Bold)
$TextBox.Text = "00"
$form.Controls.Add($textBox)

#$form.Add_Shown({$textBox.Select()})

$labeltips = new-object System.Windows.Forms.Label
$labeltips.text = "dB. 0dB输入00`r`n    5dB输入05"
$labeltips.Location = New-Object Drawing.Point(890, 290)
$labeltips.Size = New-Object Drawing.Point(240, 40)
$Form.controls.add($labeltips)

$btnruniperf = New-Object Windows.Forms.Button
$btnruniperf.text = "Run iperf3"
$btnruniperf.Location = New-Object Drawing.Point(750, 350)
$btnruniperf.Size = New-Object Drawing.Point(120, 50)
$btnruniperf.add_click({ btnRuniperfClick })
$Form.controls.add($btnruniperf)

$btnopenresult1 = New-Object Windows.Forms.Button
$btnopenresult1.text = "获取结果"
$btnopenresult1.Location = New-Object Drawing.Point(880, 350)
$btnopenresult1.Size = New-Object Drawing.Point(120, 50)
$btnopenresult1.add_click({ btnGetResultClick })
$Form.controls.add($btnopenresult1)

$label = new-object System.Windows.Forms.RichTextBox
$label.text ="初始化完成"
$label.Location = New-Object Drawing.Point(40,90)
$label.Size = New-Object Drawing.Point(700,300)
$label.Multiline = $true
#$label.Font = "Lucida Console" 
$label.WordWrap = $false 
$Form.controls.add($label)

$btnopenresult = New-Object Windows.Forms.Button
$btnopenresult.text = "打开结果目录"
$btnopenresult.Location = New-Object Drawing.Point(40, 500)
$btnopenresult.Size = New-Object Drawing.Point(120, 50)
$btnopenresult.add_click({ btnopenResultClick })
$Form.controls.add($btnopenresult)

$btnclear = New-Object Windows.Forms.Button
$btnclear.text = "清除日志"
$btnclear.Location = New-Object Drawing.Point(660, 390)
$btnclear.add_click({ btnclearClick })
$Form.controls.add($btnclear)

function printf($str)
{
	Write-Host $str
	$label.AppendText("`r`n" + ($str))
}

function btneditClick
{
	printf "打开配置文件"
	notepad.exe "$(pwd)\config.bat"
	#D:\02-Install_Tools\Notepad++\notepad++.exe "$(pwd)\config.bat"
	printf "编辑完成后，请保存并关闭配置文件"
}

function btn2Click
{
    printf "打开文件"
    #explorer.exe "$(pwd)\result"
    notepad.exe "$(pwd)\config.bat"
}


$global:iperfpid = $null
function btnStartClick
{
    printf "开始测试"
	$myprocss = Start-Process -FilePath .\autotest.bat -passthru -verb runas
	$global:iperfpid = $myprocss.Id
}

function btnStopClick
{
	printf "强制结束测试"
	Stop-Process -Id $iperfpid
	Write-Host $iperfpid
	printf "已结束测试"
}

function btnATTClick
{
	#Write-Host "设置ATT=$($TextBox.text) "
	printf "设置ATT=$($TextBox.text) "
	$ATT=$TextBox.text
	switch ($ATT)
	{
		0{ $ATT = "00" }
		1{ $ATT = "01" }
		2{ $ATT = "02" }
		3{ $ATT = "03" }
		4{ $ATT = "04" }
		5{ $ATT = "05" }
		6{ $ATT = "06" }
		7{ $ATT = "07" }
		8{ $ATT = "08" }
		9{ $ATT = "09" }
	}
	Write-Host "ATT=$ATT"
	Start-Process -FilePath .\att.bat $ATT -WindowStyle Hidden -passthru -verb runas
}

function btnZPgoClick
{
	$JDval = $textBoxgo.Text
	switch ($JDval)
	{
		1{ printf "转盘前进1度" }
		5{ printf "转盘前进5度" }
		10{ printf "转盘前进10度" }
		15{ printf "转盘前进15度" }
		30{ printf "转盘前进30度" }
		60{ printf "转盘前进60度" }
		90{ printf "转盘前进90度" }
		360{ printf "转盘前进360度" }
		default {
			$JDval = 30
			printf "转盘前进30度"
			$textBoxgo.Text=30
		}
	}
	
	#printf "转盘前进：$($JDval) "
	Start-Process -FilePath .\zp.bat "go $($JDval)"  -WindowStyle Hidden -passthru 
	
	$sleeptime = $JDval/30 * 6000
	printf "请等待：$($sleeptime/1000)秒 "
	
}
function btnZPbackClick
{
	$JDval2 = $textBoxback.Text
	switch ($JDval2)
	{
		1{ printf "转盘后退1度" }
		5{ printf "转盘后退5度" }
		10{ printf "转盘后退10度" }
		15{ printf "转盘后退15度" }
		30{ printf "转盘后退30度" }
		60{ printf "转盘后退60度" }
		90{ printf "转盘后退90度" }
		360{ printf "转盘后退360度" }
		default {
			$JDval = 30
			printf "转盘后退30度"
			$textBoxback.Text = 30
		}
	}
	
	$myprocss = Start-Process -FilePath .\zp.bat "back $($JDval2)" -WindowStyle Hidden -passthru -verb runas
	
	$sleeptime = $JDval2/30 * 6000
	printf "请等待：$($sleeptime/1000)秒 "
	#Start-Sleep -Milliseconds $sleeptime
	#printf "转盘后退：$($JDval2) "
	
}

function btnRuniperfClick
{
	printf "开始Iperf3打流,请等待30秒"
	#Start-Process -FilePath .\iperf.bat "$($TextBox.text)" -WindowStyle Hidden  -passthru -verb runas 
	$prog= Start-Process -FilePath .\iperf.bat "$($TextBox.text)" -passthru -verb runas
	#Start-Sleep -Seconds 5
	printf $prog.Id
	Wait-Process -ProcessId $prog.Id -TimeoutSec 5
	btnGetResultClick
	
}

function btnopenResultClick
{
	printf "打开结果所在文件夹"
	explorer.exe "$(pwd)\result"
}

function btnGetResultClick
{
	printf "正在检查是否生成测试结果"
	
	$finishflag = ".\test_finished"
	
	if (Test-Path -Path $finishflag)
	{
		$resultfilename = Get-Content $finishflag
		$resultdata = @(Get-Content "$resultfilename")
		printf 结果如下：
		foreach ($line in $resultdata)
		{
			printf $line
		}
		
	}
	else
	{
		printf "没有获取到结果"
	}
}

function btnclearClick
{
	$label.text = "清除日志"
}
#$form.Topmost = $true

#$form.Add_Shown({ $textBox.Select() })
#$result = $form.ShowDialog()


[System.Windows.Forms.Application]::EnableVisualStyles() | Out-Null;
[System.Windows.Forms.Application]::Run($Form) | Out-Null;

