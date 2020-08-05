<!DOCTYPE html>

<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
  String path = request.getContextPath();
  String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <base href="<%=basePath%>">
  <title>My JSP 'plupload.jsp' starting page</title>
  <script type="text/javascript" src="plupload/js/jquery.js"></script>
  <link type="text/css" rel="stylesheet" href="layui/layui/css/layui.css"/>
  <!-- 首先需要引入plupload的源代码 -->
  <script src="pluploadMaster/js/plupload.full.min.js"></script>
  <script type="text/javascript" src="layui/layui/layui.all.js" charset="UTF-8"></script>
</head>

<body>
<!-- 这里我们只使用最基本的html结构：一个选择文件的按钮，一个开始上传文件的按钮(甚至该按钮也可以不要) -->
<div class="layui-upload">
  <button type="button" class="layui-btn layui-btn-normal" id="testList">添加4444444</button>
  <div class="layui-upload-list">
    <table class="layui-table">
      <thead>
      <tr><th>单位名称</th>
        <th>文件名</th>
        <th>上传进度</th>
        <th>状态</th>
        <th>操作</th>
      </tr></thead>
      <tbody id="demoList"></tbody>
    </table>
  </div>
  <button type="button" class="layui-btn" id="uploadfiles">开始上传</button>

  <a href="/FileUpload/Index">文件上传</a>
  <a href="/ImageUpload/Index">图片上传</a>
  <a href="/BigFileUpload/Index">大文件上传</a>
  <a href="/MultiPickerUpload/Index">多选择器多文件上传</a>
</div>

<script>
    layui.use(['upload','element','layer'], function(){
        var $ = layui.jquery;
        var upload = layui.upload,element = layui.element,layer = layui.layer;
        //实例化一个plupload上传对象
        var uploader = new plupload.Uploader({
            browse_button : 'testList', //触发文件选择对话框的按钮，为那个元素id
            url : 'plupload', //服务器端的上传页面地址
            flash_swf_url : 'pluploadMaster/js/Moxie.swf', //swf文件，当需要使用swf方式进行上传时需要配置该参数
            silverlight_xap_url : 'pluploadMaster/js/Moxie.xap' ,//silverlight文件，当需要使用silverlight方式进行上传时需要配置该参数
            max_file_size : '10240mb',
            chunk_size : '10mb',
            resize : {
                width : 200,
                height : 200,
                quality : 90,
                crop : true
            },
            drop_elementL: "testList",
            init : {
                PostInit : function() {
                    $("#uploadfiles").click (function() {
                        var isUpload = confirm("是否确定要上传文件?");
                        if(isUpload){
                            uploader.start();// 开始上传
                            return false;
                        }
                    });
                },
                FilesAdded : function(up, files) {
                    plupload.each(files, function(file) {
                        console.log(file,"file");
                        var tr = $(['<tr id="'+ file.id +'" class="uptr">'
                            ,'<td>公司</td>'
                            ,'<td>'+ file.name +'</td>'
                            ,'<td>'
                            +'<div  file="'+file.name+'" class="layui-progress layui-progress-big"  lay-showPercent="true"   lay-filter="'+file.id+'">'
                            +'<div  class="layui-progress-bar layui-bg-red" lay-percent="0%"><span class="layui-progress-text">0%</span></div>'
                            /*  +'<input name="pr" value="'+file.name+'" type="hidden" >'*/
                            +'</div>'
                            , '</td>'
                            ,'<td class="upfile" id="upstatus">等待上传</td>'
                            ,'<td>'
                            ,'<button class="layui-btn layui-btn-xs demo-reload layui-hide">重传</button>'
                            ,'<button class="layui-btn layui-btn-xs layui-btn-danger demo-stop">暂停</button>'
                            ,'<button class="layui-btn layui-btn-xs layui-btn-danger demo-start">继续</button>'
                            ,'<button class="layui-btn layui-btn-xs layui-btn-danger demo-delete">删除</button>'
                            ,'<button class="layui-btn layui-btn-xs layui-btn-danger demo-upload">下载</button>'
                            ,'</td>'
                            ,'</tr>'].join(''));
                        $('#demoList').append(tr);

                    });
                    plupload.each(files, function(file) {  //主要针对每个文件的删除操作
                        $("#"+file.id+" .demo-delete").click(function() {
                            console.log(file,"file删除触发")
                            if(file.status==2){
                                alert("文件《"+file.name+"》正在上传，请不要删除！");
                            }/* else if(file.status==5){
								alert("文件《"+file.name+"》已经上传成功，不可以删除！");
							} */else{
                                var gnl = confirm("确定要删除《"+file.name+"》?");
                                if (gnl == true) {
                                    $("#"+file.id).remove();
                                    up.removeFile(file);
                                }/*  else {
										return false;
							} */
                            }
                        });

                        $("#"+file.id+" .demo-stop").click(function(a, b, c) {
                            console.log(a, b, c)
                            up.stop();// 停止上传
                            file.status = 1
                            console.log(file,"file暂停444")
                        });

                        $("#"+file.id+" .demo-start").click(function() {
                            up.start();// 继续上传
                            file.status = 2
                            console.log(file,"file开始")
                        });
                    });
                },
                UploadProgress : function(up, file) {//显示文件上传的状态
                    //_mask();
                    var percent = file.percent;
                    element.progress(file.id, percent+"%")
                    //_mask();
                },// 文件上传成功的时候触发，针对于每一个文件；这里主要返回文件上传成功与否的状态，
                FileUploaded : function(up, file, info) {
                    /* var data = eval("(" + info.response + ")");// 解析返回的json数据
                    if (data.code == 3) {
                        alert( "文件《"+file.name+"》上传失败！");
                    } */
                },
                UploadComplete : function(up, files) {//队列中的所有文件上传完后，触发
                    if(files.length<=0){
                        alert("请先添加文件进行，并上传！");
                    }else{
                        var arr2 = new Array();
                        plupload.each(files, function(file) {
                            console.log(file.status);
                            if (file.status == 5) {//将上传成功的文件信息发送到后台进行处理
                                var json = {
                                    docId:file.id,
                                    docName : file.name,
                                    fileSize : plupload.formatSize(file.size)
                                };
                                arr2.push(json);
                            }
                        });
                        console.log(arr2);
                        arr2 = JSON.stringify(arr2);
                        $("#uploadfilelist").val(arr2);//将结果传给前台，以便统一操作
                        //alert( "文件上传完成");

                        plupload.each(files, function(file) {
                            $("#"+file.id+" .demo-upload").click(function() {
                                var $eleForm = $("<form method='get'></form>");

                                $eleForm.attr("action","http://localhost:8088/mbpm/plupload22/files/"+file.name);

                                $(document.body).append($eleForm);

                                //提交表单，实现下载
                                $eleForm.submit();
                            });
                        })

                    }
                },
                Error : function(up, err,file) { // 上传出错的时候触发
                    if(err.code=="-600"){
                        alert("文件："+err.file.name+"太大，超过100mb!");
                    }else{
                        alert( err.file.name+"添加上传队列失败！错误原因："+err.message);
                    }
                }
            }
        });

        //在实例对象上调用init()方法进行初始化
        uploader.init();

        //绑定各种事件，并在事件监听函数中做你想做的事
        uploader.bind('FilesAdded',function(uploader,files){
            console.log(uploader, files, 8888)
            //每个事件监听函数都会传入一些很有用的参数，
            //我们可以利用这些参数提供的信息来做比如更新UI，提示上传进度等操作
        });
        uploader.bind('UploadProgress',function(uploader,file){
            //每个事件监听函数都会传入一些很有用的参数，
            //我们可以利用这些参数提供的信息来做比如更新UI，提示上传进度等操作
        });
        uploader.bind('BeforeUpload',function(uploader,file){
            console.log(uploader, file, "BeforeUpload")
            //每个事件监听函数都会传入一些很有用的参数，
            //我们可以利用这些参数提供的信息来做比如更新UI，提示上传进度等操作
        });
        //......
        //......

        /*    //最后给"开始上传"按钮注册事件
            document.getElementById('start_upload').onclick = function(){
                uploader.start(); //调用实例对象的start()方法开始上传文件，当然你也可以在其他地方调用该方法
            } */
    });
</script>
</body>
</html>
