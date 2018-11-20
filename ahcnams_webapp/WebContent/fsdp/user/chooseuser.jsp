<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="/common/taglibs2.jsp"%>

<!doctype html>
<html>
<head>

${style_css }
${jquery_js }
${finedo_core_js }
${finedo_commonui_js }
${finedo_grid_js }
${finedo_dialog_js }
${finedo_tree_js }
${vue_js }
</head>

<body class="query-body">
<div id="chooseuser-template">
	<div id="leftdiv" style="width:250px; float:left; border:1px solid #ddd; position:fixed; top: 20px; left: 10px; bottom: 10px; overflow-y: auto; overflow-x: auto;">
		<div class="tree-name">组织结构</div>
		<ul id="treediv" class="fdtree" style="margin-left: 5px;"></ul>
	</div>
	<div id="rightdiv" style="width:auto; float:right; position:fixed; top:20px; left:270px; bottom:10px;">
		<table class="finedo-table" style="height:100%;">
            <tr style="height:26px;">  
                <td colspan="3">
	                <input type="text" class="finedo-text" id="query-box-text" v-model="usercode"
		                onfocus="if(this.value == '请输入人员姓名、工号、号码或邮箱查询'){this.value='';}" onblur="if(this.value==''){this.value='请输入人员姓名、工号、号码或邮箱查询'}"
                        @keyup.13="doquery()">
		            <input type="button" value="查询" class="finedo-button-blue" v-on:click="doquery">
		            <input type="button" class="finedo-button" value="确定选择" v-on:click="chooseSubmit">
                </td>  
            </tr> 
			<tr>
				<td style="vertical-align: top;width:45%;">
				    待选择人员(<font color=blue>双击选择</font>)：<br />
					<select v-model="canselectctl" id="leftSelect" name="leftSelect" v-on:dblclick="canselectdbclick" multiple="multiple" style="width:100%;">
					   <option v-for="(item,index) in canselectList" v-bind:value="index">{{item.personname}}({{item.usercode}})</option>
					</select>
				</td>
				<td style="vertical-align: middle;text-align:center;">
				    <input id="btnRight" name="btnRight" type="button" class="finedo-button-green" v-on:click="selectall"
						value="全部选择>>">
                    <br />
                    <input id="btnLeft" name="btnLeft" type="button" class="finedo-button" v-on:click="unselectall"
						value="<<全部不选" >
                </td>
		        <td style="vertical-align:top;width:45%;">
		                      已选择人员(<font color=blue>双击删除</font>)：<br/>
                    <select v-model="selectedctl" id="rightSelect" name="rightSelect" v-on:dblclick="selecteddbclick" multiple="multiple" style="width:100%;">
                        <option v-for="(item,index) in selectedList" v-bind:value="index">{{item.personname}}({{item.usercode}})</option>
		            </select>
		        </td>
            </tr>
        </table>
    </div>
</div>
<script>
var chooseuservue;
var vm = new Vue({
    el: '#chooseuser-template',
    data: {
        orgid:'',//绑定点击的组织机构标识
        usercode:'请输入人员姓名、工号、号码或邮箱查询',//绑定输入的查询条件
        canselectctl:[],//绑定可选列表中当前选中项
        selectedctl:[],//绑定已选列表中当前选中项
        selectedList:[],//绑定已选列表
        canselectList:[]//绑定可选列表
    },
    mounted: function(){
        chooseuservue = this;
        window.onresize = function(){
            chooseuservue.resize();
        }
        this.resize();
        this.initOrgTree();
        this.initSelectedVal();
    },
    methods: {
    	resize:function(){
    		$("#rightdiv").width(document.body.clientWidth - 280);
            $("#leftSelect").height($("#rightdiv").height() - 90);
            $("#rightSelect").height($("#rightdiv").height() - 90);
        },
        initOrgTree:function(){
        	const that = this;
        	finedo.getTree('treediv', {
                url : '${ctx}/finedo/organization/queryorgtree',
                async : true,
                selecttype : 'single',
                onclick : function(retdata){
                    chooseuservue.orgid = retdata.id;
                    chooseuservue.doquery();
                }
            });
        },
        initSelectedVal:function(){
        	var selectedUsercode = "${param.usercode}";
        	if(selectedUsercode == ''){
        		return;
        	}
        	finedo.action.ajax({
                url:'${ctx}/finedo/user/querybyusercode',
                data:{'usercode':selectedUsercode},
                callback:function(retdata){
                    if(retdata.fail){
                        finedo.message.error(retdata.resultdesc);
                        return;
                    }
                    var retdatalist = retdata.object;
                    retdatalist.forEach(function(element,index,data){
                        chooseuservue.selectedList.push(element);
                    });
                }
            });
        },
        doquery:function(){
        	var querycode = $.trim(this.usercode);
        	if(querycode == '请输入人员姓名、工号、号码或邮箱查询'){
        		querycode = '';
        	}
        	if(this.orgid == '' && querycode == ''){
        		finedo.message.tip('请输入查询条件');
        		return;
        	}
        	this.canselectList.splice(0, this.canselectList.length);
        	var userids = '';
        	this.selectedList.forEach(function(element,index,data){
                if(userids != ''){
                	userids += ',';
                }
                userids += element.usercode;
            });
        	finedo.action.ajax({
        		url:'${ctx}/finedo/user/querybyselect',
        		data:{'orgnode':this.orgid, 'usercode':querycode, 'userid':userids},
        		callback:function(retdata){
                    if(retdata.fail){
                    	finedo.message.error(retdata.resultdesc);
                    	return;
                    }
                    var retdatalist = retdata.object;
                    retdatalist.forEach(function(element,index,data){
                        chooseuservue.canselectList.push(element);
                    });
                }
        	});
        },
        selectall:function(){
        	this.canselectList.forEach(function(element,index,data){
        	    chooseuservue.selectedList.push(element);
        	});
        	this.canselectList.splice(0, this.canselectList.length);
        },
        unselectall:function(){
            this.selectedList.forEach(function(element,index,data){
                chooseuservue.canselectList.push(element);
            });
        	this.selectedList.splice(0, this.selectedList.length);
        },
        chooseSubmit:function(){
        	finedo.dialog.closeDialog(this.selectedList);
        },
        canselectdbclick:function(){
        	var selectedIndex = this.canselectctl[0];
            this.selectedList.push(this.canselectList[selectedIndex]);
            this.canselectList.splice(selectedIndex, 1);
        },
        selecteddbclick:function(){
        	var selectedIndex = this.selectedctl[0];
        	this.canselectList.push(this.selectedList[selectedIndex]);
        	this.selectedList.splice(selectedIndex, 1);
        }
    }
})
</script>
</body>
</html>
