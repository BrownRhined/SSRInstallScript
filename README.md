# ShadowsocksR auto install
## 特別感謝
修改自Hao-Luo大佬的SSR腳本！
<br>https://github.com/Hao-Luo/
<br>感謝Teddysun的BBR腳本！
<br>https://github.com/teddysun/
## 說明
安裝完需手動配置。
<br>腳本在centos7上測試通過，其他發行版未測試。
## 使用方法
````
wget -N --no-check-certificate https://raw.githubusercontent.com/BrownRhined/SSRInstallScript/master/Install.sh;chmod +x Install.sh;./Install.sh
````
<br>複製上方代碼並執行開始安裝。
##腳本功能
````
1.檢查是否安装了git、libsodium（可能會有點慢）。
2.選擇安裝功能，
  1）SSR
  2）BBR
  3）定時重啟節點
3.BBR安装之後需要reboot。
4.SSR安装之後請手動更改配置即可。
配置文件 userapiconfig.py
API接口：mudbjson, sspanelv2, sspanelv3, sspanelv3ssr, glzjinmod, legendsockssr，根据面板要求输入。
mysql伺服器地址：SSR和資料庫在同一台伺服器输入127.0.0.1，遠端節點填寫資料庫IP。
mysql伺服器端口：默認port輸入3306，更改過的輸入自己的端口。
mysql伺服器用户名：root或者其他設置的用户名。
mysql伺服器密码:与用户名對應的密码。
mysql伺服器資料庫名:前端建立資料庫时的資料庫名，ssrpanel或其他。
SSR节点ID（nodeid）:前端建立节点时的ID。
加密（method）：SSR的加密方式，aes-256-cfb等。
协议（protocol）：SSR的协议插件，origin等。
混淆（obfs）：SSR的混淆插件，plain等。
5.配置完成會關閉iptables、firewalld，大佬請自行设置。
6.輸入 pthon server.py 進行測試
````
