<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="/common/taglibs2.jsp" %>

<!doctype html>
<html>
<head>
${style_css }
${jquery_js }
${finedo_core_js }
${finedo_commonui_js }
${finedo_dialog_js }

<script>

// 数据验证
function checkdata() {
   /**
 	* 	通用数据验证
 	* 	label  		名称
	*	datatype 	数据类型  string email phone url date datetime time number digits 
	*	minlength 	最小长度
	*	maxlength 	最大长度
	*	required 	是否必填 true/false
	*/
	var result=finedo.validate({
		"name":{label:"定时任务名称", datatype:"string", required:true},
		"beanname":{label:"Bean类名", datatype:"string", required:true},
		"method":{label:"Bean类方法名", datatype:"string", required:true},
		"cron":{label:"CRON", datatype:"string", required:true}
	});
   
	var cron=$('#cron').val();
	if(cron.split(" ").length != 6 && cron.split(" ").length != 7) {
		finedo.showhinterror("cron", "CRON格式不正确!");
		return;
	}
	
	return result;
}

// 提交
function doNext() {
	dosubmit();
}

// 普通新建
function dosubmit() {
	if(!checkdata()) 
		return;

	var form = $("#ajaxForm");
	var options = {     
        url:	   form.attr("action"),
        success:   submitcallback,
        type:      'POST',
        dataType:  "json",
	    clearForm: false
    };
	finedo.message.showWaiting();
	form.ajaxSubmit(options);
}

function submitcallback(jsondata){
	finedo.message.hideWaiting();
	finedo.message.info(jsondata.resultdesc, "新建定时器信息");
}
</script>
</head>

<body>
<div>
	<div class="add-common-head">
    	<div class="add-common-name-add">修改定时器信息<br/></div>
        <input type="button" class="finedo-button-blue" style="float:right" value="提交" onclick="doNext();">
    </div>
    
    <form method="post" action="${ctx }/finedo/timer/modify" id="ajaxForm" name="ajaxForm">
    <input type="hidden" id="id" name="id" value="${timertask.id}">
    <input type="hidden" id="optrid" name="optrid" value="${sessionScope.LOGINDOMAIN_KEY.sysuser.userid}">
    <div id="common_add_div" >
    	<div class="finedo-nav-title">基本信息</div>
	   	<ul class="finedo-ul">
	   		<li>
				<span class="finedo-label-title"><font color=red>*</font>技术说明</span>
				<span class="finedo-label-info">1) 定时器类必须声明@Component、@Control、@Service注解, 否则Spring不会加载该类</span>
				<span class="finedo-label-info">2) 新增、修改、删除定时器重启应用服务器才能生效</span>
			</li>
			
			<li>
				<span class="finedo-label-title"><font color=red>*</font>定时任务名称</span>
				<fsdp:text id="name" value="${timertask.name}"/>
			</li>

           	<li>
           		<span class="finedo-label-title"><font color=red>*</font>Bean类名</span>
           		<fsdp:text id="beanname" hint="请填写Bean类名，如：CleanerTimer,注意不需要前面的package名" value="${timertask.beanname}"/>
           	</li>

           	<li>
           		<span class="finedo-label-title"><font color=red>*</font>Bean类方法名</span>
           		<fsdp:text id="method" hint="请填写需要执行的Bean类方法名，如：doWork" value="${timertask.method}"/>
           	</li>
           	
           	<li>
           		<span class="finedo-label-title"><font color=red>*</font>CRON</span>
           		<fsdp:text id="cron" value="${timertask.cron}" hint="如: 每5分钟执行一次示例: * 0/5 * * * *, 格式说明: 秒 分 时 日 月 星期, 其中以空格间隔"/>
           	</li>
		</ul>
		 <ul>
	    	<li class="add-center"><input type="button" class="finedo-button" value="提    交" onClick="dosubmit()" ></li>
	    </ul>
	    
	    <hr></hr>
<pre style="line-height:25px; background:#fff; padding:5px; font-family:Microsoft Yahei, SimSun; }">
<b>CRON配置方法说明：</b>
一、CRON表达式是一个字符串，字符串以5或6个空格隔开，分开共6或7个域，每一个域代表一个含义,CRON有如下两种语法 
格式： 
Seconds Minutes Hours DayofMonth Month DayofWeek Year 或 
Seconds Minutes Hours DayofMonth Month DayofWeek 
二、每一个域可出现的字符如下
Seconds:可出现,-  *  / 四个字符，有效范围为0-59的整数    
Minutes:可出现,-  *  / 四个字符，有效范围为0-59的整数    
Hours:可出现,-  *  / 四个字符，有效范围为0-23的整数    
DayofMonth:可出现,-  *  / ? L W C八个字符，有效范围为0-31的整数     
Month:可出现,-  *  / 四个字符，有效范围为1-12的整数或JAN-DEc    
DayofWeek:可出现,-  *  / ? L C #四个字符，有效范围为1-7的整数或SUN-SAT两个范围。1表示星期天，2表示星期一， 依次类推    
Year:可出现,-  *  / 四个字符，有效范围为1970-2099年   

三、每一个域都使用数字，但还可以出现如下特殊字符，它们的含义是：
1)*：表示匹配该域的任意值，假如在Minutes域使用*,即表示每分钟都会触发事件。    
2)?:只能用在DayofMonth和DayofWeek两个域。它也匹配域的任意值，但实际不会。因为DayofMonth和DayofWeek会相互影响。例如想在每月的20日触发调度，不管20日到底是星期几，则只能使用如下写法： 13  13 15 20 * ?,其中最后一位只能用？，而不能使用*，如果使用*表示不管星期几都会触发，实际上并不是这样。    
3)-:表示范围，例如在Minutes域使用5-20，表示从5分到20分钟每分钟触发一次    
4)/：表示起始时间开始触发，然后每隔固定时间触发一次，例如在Minutes域使用5/20,则意味着5分钟触发一次，而25，45等分别触发一次.    
5),:表示列出枚举值值。例如：在Minutes域使用5,20，则意味着在5和20分每分钟触发一次。    
6)L:表示最后，只能出现在DayofWeek和DayofMonth域，如果在DayofWeek域使用5L,意味着在最后的一个星期四触发。    
7)W:表示有效工作日(周一到周五),只能出现在DayofMonth域，系统将在离指定日期的最近的有效工作日触发事件。例如：在DayofMonth使用5W，如果5日是星期六，则将在最近的工作日：星期五，即4日触发。如果5日是星期天，则在6日触发；如果5日在星期一到星期五中的一天，则就在5日触发。另外一点，W的最近寻找不会跨过月份    
8)LW:这两个字符可以连用，表示在某个月最后一个工作日，即最后一个星期五。    
9)#:用于确定每个月第几个星期几，只能出现在DayofMonth域。例如在4#2，表示某月的第二个星期三。    
</pre>

<ul class="finedo-ul">
	<li>
		<span class="finedo-label-title" style="width:150px;"><font color=red>0 0 2 1 * ? *</font></span>
		<span class="finedo-label-info">表示在每月的1日的凌晨2点调度任务</span>
    </li>
    
    <li>
		<span class="finedo-label-title" style="width:150px;"><font color=red>0 15 10 ? * MON-FRI</font></span>
		<span class="finedo-label-info">表示周一到周五每天上午10：15执行作业</span>
    </li>
    
    <li>
		<span class="finedo-label-title" style="width:150px;"><font color=red>0 15 10 ? 6L 2002-2006</font></span>
		<span class="finedo-label-info">表示200-2006年的每个月的最后一个星期五上午10:15执行作业</span>
    </li>
    
    <li>
		<span class="finedo-label-title" style="width:150px;"><font color=red>0 0 10,14,16 * * ?</font></span>
		<span class="finedo-label-info">每天上午10点，下午2点，4点</span>
    </li>
    
    <li>
		<span class="finedo-label-title" style="width:150px;"><font color=red>0 0/30 9-17 * * ?</font></span>
		<span class="finedo-label-info">朝九晚五工作时间内每半小时</span>
    </li>
    
    <li>
		<span class="finedo-label-title" style="width:150px;"><font color=red>0 0 12 ? * WED</font></span>
		<span class="finedo-label-info">表示每个星期三中午12点</span>
    </li>
    
    <li>
		<span class="finedo-label-title" style="width:150px;"><font color=red>0 0 12 * * ?</font></span>
		<span class="finedo-label-info">每天中午12点触发 </span>
    </li>
    
    <li>
		<span class="finedo-label-title" style="width:150px;"><font color=red>0 15 10 15 * ?</font></span>
		<span class="finedo-label-info">每月15日上午10:15触发</span>
    </li>
    
    <li>
		<span class="finedo-label-title" style="width:150px;"><font color=red>0 15 10 L * ?</font></span>
		<span class="finedo-label-info">每月最后一日的上午10:15触发 </span>
    </li>
    
    <li>
		<span class="finedo-label-title" style="width:150px;"><font color=red>0 15 10 ? * 6L</font></span>
		<span class="finedo-label-info">每月的最后一个星期五上午10:15触发</span>
    </li>   
</ul>
    </div>
    </form>
</div>
</body>
</html>
