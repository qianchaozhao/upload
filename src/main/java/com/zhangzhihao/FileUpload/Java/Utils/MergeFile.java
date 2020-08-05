package com.zhangzhihao.FileUpload.Java.Utils;

import com.sun.istack.internal.NotNull;
import org.apache.tomcat.util.http.fileupload.FileUtils;
import org.springframework.util.StreamUtils;

import java.io.*;
import java.nio.file.Files;
import java.util.*;

import static com.zhangzhihao.FileUpload.Java.Utils.DeleteFolder.deleteFolder;
import static com.zhangzhihao.FileUpload.Java.Utils.StreamUtil.saveStreamToFile;


public class MergeFile {

    /**
     * @param chunksNumber
     * @param ext
     * @param guid
     * @param uploadFolderPath
     * @throws Exception
     */
    public static void mergeFile(final int chunksNumber,
                                 @NotNull final String ext,
                                 @NotNull final String guid,
                                 @NotNull final String uploadFolderPath,
                                 @NotNull final String md5

                                 )
            throws Exception {




        /*合并输入流*/
        String mergePath = uploadFolderPath + guid + "/";

        File file = new File(mergePath);

        File[] files = file.listFiles();

        List<FileInputStream> list = new ArrayList<FileInputStream>();

        for (File f : files) {
            list.add(new FileInputStream(f));
        }

        //使用 Enumeration（列举） 将文件全部列举出来
        Enumeration<FileInputStream> eum = Collections.enumeration(list);
        //SequenceInputStream合并流 合并文件
        SequenceInputStream s = new SequenceInputStream(eum);


//        SequenceInputStream s ;
//        InputStream s1 = new FileInputStream(mergePath + 0 + ext);
//        InputStream s2 = new FileInputStream(mergePath + 1 + ext);
//        s = new SequenceInputStream(s1, s2);
//        for (int i = 2; i < chunksNumber; i++) {
//            InputStream s3 = new FileInputStream(mergePath + i + ext);
//            s = new SequenceInputStream(s, s3);
//        }

        //通过输出流向文件写入数据
        saveStreamToFile(s, uploadFolderPath + md5 + ext);

        //删除保存分块文件的文件夹
        deleteFolder(mergePath);

    }
}
