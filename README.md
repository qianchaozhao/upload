# FileUpload.Java [![Build Status](https://travis-ci.org/izhangzhihao/FileUpload.Java.svg?branch=master)](https://travis-ci.org/izhangzhihao/FileUpload.Java)
# 文件上传，图片上传(后缀名验证，文件类型验证)，大文件分片上传，“秒传”，断点续传，传输失败自动重试，手动重试

1.主要功能经测试支持IE9以上，Chrome，FireFox；其他浏览器未测试；

2.文件上传部分：主要实现了文件的上传，进度条，多文件一起上传，上传前删除，上传失败后手动删除，上传失败自动重试，上传失败手动重试（retry按钮），自动上传；

3.大文件上传部分：重磅功能：大文件“秒传”；在文件上传部分已有功能的基础上实现了按10MB分为多个块，异步上传，服务端合并，MD5验证，文件秒传，断点续传，网络问题自动重试，手动重试；

4.图片上传部分：在文件上传部分已有功能的基础上实现了上传前缩略图预览，前台js文件后缀验证，后台代码文件后缀验证和文件类型验证（就算修改后缀名也无法成功上传），支持图片上传前压缩；

5.多选择器多文件上传：通过不同的文件选择器选择不同的文件，最后同时上传，Controller只是简单示意，并没有详细写实现，具体怎么做可参照上面的其它上穿方法。

# 文件上传这里好多方法可以抽象出来，当然这个项目只是一个示例，所以我偷了点懒，应用到生产环境时还要根据环境选择保存到不同的文件路径等等，大家根据自己的情况自己封装方法吧。



以下是我修改后的提示:

根据其他项目进行修改的多文件上传断点续传,多文件下载续传, 以及刷新页面,或者隔天都可以进行续传

技术:
springboot
webuploader(多文件断点上传) 
webuploader官网: http://fex.baidu.com/webuploader/doc/index.html#WebUploader_Uploader_events

ajax(多文件断点下载)

上传下载的断点记录还没做


