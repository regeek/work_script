#!/usr/bin/perl

use strict;
use warnings;

####################
#main
####################
my $data_length = 10;
my @array_bin = ();
my $cnt_array = 0;
my $msg_01 = "削除データ（定期）に変換しました";
my $msg_02 = "削除データに変換できません";
my $msg_03 = "提供データの改行を削除していない可能性があります";
my $msg_04 = "引数を指定して下さい";
my $msg_05 = "ファイルが存在しません";
my $msg_06 = "削除データ（初期）に変換しました";

my $num_argv = @ARGV;
if($num_argv > 0){
    foreach my $file(@ARGV){
        if( -f $file){
            my $filesize = `ls -l $file | awk '{ print \$5 }'`;
            #shellの結果に改行が含まれるため、改行を削除
            chomp($filesize);

            if( ($filesize % $data_length) == 0 && ($file =~ /^FFFFF[2|3|5]11/ ) ){
                ReadFile_Teiki($file);
                $cnt_array = @array_bin;
                WriteFile_Teiki($file);

                print "FILENAME:$file, FILESIZE:$filesize byte, $msg_01\n";
            }
            elsif( ($filesize % $data_length) == 0 && ($file =~ /^FFFFF001/) ){
                ReadFile_Shoki($file);
                $cnt_array = @array_bin;
                WriteFile_Shoki($file);

                print "FILENAME:$file, FILESIZE:$filesize byte, $msg_06\n";
            }else{
                print "FILENAME:$file, FILESIZE:$filesize byte, $msg_02, $msg_03\n";
            }
        }
        else{
            print "FILENAME:$file, $msg_05\n";
        }
    }
}
else{
    print "$msg_04\n";
}

####################
#subroutine
####################
sub ReadFile_Teiki{
    my $file = $_[0];
    my $cnt = 0;
    my $buf = "";

    open(IN,"+<",$file) or die "$!";
    binmode IN;

    while (read IN, $buf, $data_length) {
        #データ種類とデータ種類以外のデータで分割
        #データ種類以外のデータのみ使用
        my ( $syurui, $data) = unpack "a1 a9", $buf;
        $array_bin[$cnt][0] = $syurui;
        $array_bin[$cnt][1] = $data;

        $cnt++;
    }

    close(IN);
}

sub WriteFile_Teiki{
    my $file = $_[0];
    my $syurui_Z = "Z";
    my $buf = "";

    open(IN,"+>",$file) or die "$!";
    binmode IN;

    #削除データに書き換え
    for(my $i=0;$i<$cnt_array;$i++){
        $buf = pack "a1 a9", $syurui_Z, $array_bin[$i][1];
        print IN $buf;
    }

    close(IN);
}

sub ReadFile_Shoki{
    my $file = $_[0];
    my $cnt = 0;
    my $buf = "";

    open(IN,"+<",$file) or die "$!";
    binmode IN;

    while (read IN, $buf, $data_length) {
        #データ種類、データ種別、データ種類以外のデータで分割
        #データ種類以外のデータのみ使用
        my ( $syurui, $data1, $shubetu, $data2) = unpack "a1 a4 a1 a4", $buf;
        $array_bin[$cnt][0] = $syurui;
        $array_bin[$cnt][1] = $data1;
        $array_bin[$cnt][2] = $shubetu;
        $array_bin[$cnt][3] = $data2;

        $cnt++;
    }

    close(IN);
}

sub WriteFile_Shoki{
    my $file = $_[0];
    my $syurui_Z = "Z";
    my $shubetu_Y = "Y";
    my $buf = "";

    open(IN,"+>",$file) or die "$!";
    binmode IN;

    #削除データに書き換え
    for(my $i=0;$i<$cnt_array;$i++){
        $buf = pack "a1 a4 a1 a4", $syurui_Z, $array_bin[$i][1], $shubetu_Y, $array_bin[$i][3];
        print IN $buf;
    }

    close(IN);
}
