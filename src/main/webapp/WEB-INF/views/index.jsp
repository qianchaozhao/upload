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

  <link href="/assets/webuploader.css" rel="stylesheet" />
  <script src="/assets/webuploader.nolog.min.js"></script>
</head>

<script type="text/javascript">




    layui.use(['upload','element','layer'], function() {
        var $ = layui.jquery;
        var upload = layui.upload, element = layui.element, layer = layui.layer;

        $(function () {
            $list = $('#fileList');
            var uploader = WebUploader.create({


                //设置选完文件后是否自动上传
                auto: false,


                //swf文件路径
                //swf: BASE_URL + '~/FileUpload/Uploader.swf',
                swf: '../FileUpload/Uploader.swf',

                // 文件接收服务端。
                server: '/BigFileUpload/BigFileUp',

                // 选择文件的按钮。可选。
                // 内部根据当前运行是创建，可能是input元素，也可能是flash.
                pick: '#testList',

                chunked: true, //开启分块上传
                chunkSize: 10 * 1024 * 1024,
                chunkRetry: 3,//网络问题上传失败后重试次数
                threads: 5, //上传并发数
                //formData: { guid: WebUploader.guid() },  //一个文件有一个guid，在服务器端合并成一个文件  这里有个问题，多个文件或者上传一个文件成功后不刷新直接添加文件上传生成的guid不变！！！   暂时只能传一个大文件（已解决）
                //fileNumLimit :1,
                fileSizeLimit: 5000 * 1024 * 1024,//最大2GB
                fileSingleSizeLimit: 5000 * 1024 * 1024,


                resize: false//不压缩

                //选择文件类型
                //accept: {
                //    title: 'Images',
                //    extensions: 'gif,jpg,jpeg,bmp,png',
                //    mimeTypes: 'image/*'
                //}
            });

            // 当有文件被添加进队列的时候
            uploader.on('fileQueued', function (file, b, c) {
                console.log(file, b, c)
                var tr = $(['<tr id="'+ file.id +'" class="uptr">'
                    ,'<td>公司</td>'
                    ,'<td>'+ file.name +'</td>'
                    ,'<td>'
                    +'<div  file="'+file.name+'" class="layui-progress layui-progress-big"  lay-showPercent="true"   lay-filter="'+file.id+'">'
                    +'<div  class="layui-progress-bar layui-bg-red" lay-percent="0%"><span class="layui-progress-text">0%</span></div>'
                    +'</div>'
                    , '</td>'
                    ,'<td class="upfile" id="upstatus">等待上传</td>'
                    ,'<td id="operate">'
                    ,'</td>'
                    ,'</tr>'].join(''));
                $('#demoList').append(tr);

                uploader.options.formData.guid = WebUploader.guid();//每个文件都附带一个guid，以在服务端确定哪些文件块本来是一个

                $('#' + file.id + " #operate").text('正在计算md5值...');

                uploader.md5File(file)
                    // .progress(function(percentage) {
                    //     element.progress(file.id, (percentage * 100)+"%")
                    // })
                    .then(function (fileMd5) { // 完成
                        file.wholeMd5 = fileMd5;//获取到了md5
                        uploader.options.formData.md5value = file.wholeMd5;//每个文件都附带一个md5，便于实现秒传

                        $.ajax({//向服务端发送请求
                            cache: false,
                            type: "post",
                            //dataType: "json",
                            url: "/BigFileUpload/IsMD5Exist",//baseUrl +
                            data: {
                                fileMd5: fileMd5,
                                fileName: file.name,
                                fileID: file.id,
                                //isShared: $("#isShared").val()
                            },
                            success: function (has) {
                                if (has) {
                                    console.log("服务器上已经有同样的文件了，开始秒传！");

                                    uploader.removeFile(file, true);

                                    var opt = '<button class="layui-btn layui-btn-xs layui-btn-danger demo-upload">下载</button>'

                                    $('#' + file.id + " #operate").text("");
                                    $('#' + file.id + " #operate").append(opt);

                                } else {
                                    // console.log("服务器上没有同样的文件，秒传失败！");

                                    var opt = '<button class="layui-btn layui-btn-xs demo-reload layui-hide">重传</button>' +
                                        '<button class="layui-btn layui-btn-xs layui-btn-danger demo-stop">暂停</button>' +
                                        '<button class="layui-btn layui-btn-xs layui-btn-danger demo-start">继续</button>' +
                                        '<button class="layui-btn layui-btn-xs layui-btn-danger demo-delete">删除</button>' +
                                        '<button class="layui-btn layui-btn-xs layui-btn-danger demo-upload">下载</button>'

                                    $('#' + file.id + " #operate").text("");
                                    $('#' + file.id + " #operate").append(opt);

                                    $("#"+file.id+" .demo-delete").click(function() {
                                        console.log(file,"file删除触发")
                                        uploader.removeFile(file, true);
                                    });

                                    $("#"+file.id+" .demo-stop").click(function(a, b, c) {
                                        uploader.stop(file);// 停止上传
                                        console.log(file,"file暂停444")
                                    });

                                    $("#"+file.id+" .demo-start").click(function() {
                                        uploader.upload(file);// 继续上传
                                        console.log(file,"file开始")
                                    });

                                    var reDownload = $("#"+file.id+" .demo-upload").click(function() {

                                        var that = this;
                                        var page_url = "/BigFileUpload/download/" + fileMd5 + "." +file.ext;
                                        var req = new XMLHttpRequest();
                                        req.open("get", page_url, true);
                                        //监听进度事件
                                        req.addEventListener("progress", function (evt) {
                                            if (evt.lengthComputable) {
                                                var percentComplete = evt.loaded / evt.total;
                                                console.log(percentComplete);
                                                element.progress(file.id, (percentComplete * 100)+"%")
                                            }
                                        }, false);
                                        req.responseType = "blob";
                                        req.onreadystatechange = function () {
                                            if (req.readyState === 4 && req.status === 200) {
                                                var filename = $(that).data('filename');
                                                if (typeof window.chrome !== 'undefined') {
                                                    // Chrome version
                                                    var link = document.createElement('a');
                                                    link.href = window.URL.createObjectURL(req.response);
                                                    link.download = filename;
                                                    link.click();
                                                } else if (typeof window.navigator.msSaveBlob !== 'undefined') {
                                                    // IE version
                                                    var blob = new Blob([req.response], { type: 'application/force-download' });
                                                    window.navigator.msSaveBlob(blob, filename);
                                                } else {
                                                    // Firefox version
                                                    var file = new File([req.response], filename, { type: 'application/force-download' });
                                                    window.open(URL.createObjectURL(file));
                                                }
                                            }
                                        };

                                        $("#"+file.id+" .demo-stop").click(function(a, b, c) {
                                            req.abort();// 停止下载
                                            console.log(file,"file暂停下载")
                                        });

                                        $("#"+file.id+" .demo-start").click(function() {
                                            reDownload();// 继续下载
                                            console.log(file,"file开始下载")
                                        });

                                        req.send();

                                    });
                                }
                            }
                        });
                    });
            });


            // 文件上传过程中创建进度条实时显示。
            uploader.on('uploadBeforeSend', function (obj, params, hearders) {
                params.chunk = obj.chunk
                params.chunks = obj.chunks
                params.start = obj.start
                params.end = obj.end
                console.log(obj, params, hearders, "uploadBeforeSend")
            });

            // 文件上传过程中创建进度条实时显示。
            uploader.on('uploadProgress', function (file, percentage) {
                console.log(file, percentage, "percentage")
                element.progress(file.id, (percentage * 100)+"%")
            });

            uploader.on('uploadSuccess', function (file) {
                console.log(file, "uploadSuccess")

            });

            uploader.on('uploadError', function (file) {
                $('#' + file.id).find('p.state').text('上传出错');
                //上传出错后进度条爆红
                $('#' + file.id).find(".progress").find(".progress-bar").attr("class", "progress-bar progress-bar-danger");
                //添加重试按钮
                //为了防止重复添加重试按钮，做一个判断
                //var retrybutton = $('#' + file.id).find(".btn-retry");
                //$('#' + file.id)
                if ($('#' + file.id).find(".btn-retry").length < 1) {
                    var btn = $('<button type="button" fileid="' + file.id + '" class="btn btn-success btn-retry"><span class="glyphicon glyphicon-refresh"></span></button>');
                    $('#' + file.id).find(".info").append(btn);//.find(".btn-danger")
                }



                $(".btn-retry").click(function () {
                    //console.log($(this).attr("fileId"));//拿到文件id
                    uploader.retry(uploader.getFile($(this).attr("fileId")));

                });
            });

            uploader.on('uploadComplete', function (file) {//上传完成后回调
                //$('#' + file.id).find('.progress').fadeOut();//上传完删除进度条
                //$('#' + file.id + 'btn').fadeOut('slow')//上传完后删除"删除"按钮
            });

            uploader.on('uploadFinished', function () {
                //上传完后的回调方法
                //alert("所有文件上传完毕");
                //提交表单
            });

            $("#uploadfiles").click(function () {
                var uptrList = $(".uptr")

                for (let i = 0; i < uptrList.length; i++) {
                    if ($(uptrList[i]).find("#operate").text()  == "正在计算md5值...") {
                        alert("部分md5值未计算完")
                        return;
                    }
                }
                uploader.upload();//上传
            });

            $("#stopUploadfiles").click(function () {
                uploader.stop(true);
            });


            uploader.on('uploadAccept', function (file, response) {
                if (response._raw === '{"error":true}') {
                    return false;
                }

            });
        });
    })


</script>

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
  <button type="button" class="layui-btn" id="stopUploadfiles">停止</button>

</div>


</body>
</html>
