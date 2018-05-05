## ビルド方法
1. 外部ライブラリをビルドする
	- carthage update --platform ios --no-use-binaries
1. Twitter Appsでアプリケーションを登録し、Consumer KeyとConsumer Secretを控える
	- [Twitter Apps](https://apps.twitter.com/)
1. リバースエンジニアリング対策
	- Consumer Secretの値をconv_param.shを使い変換する
		1. sh conv_param.sh XXXXXX
		2. 出力された値をメモする
1. Consumer KeyとConsumer Secretの設定
	1. Xcodeでプロジェクトを開く
	1. 左のプロジェクトツリーから1番上のプロジェクトをクリック
	1. メインパネル上のInfoタブをクリック
	1. URL Typesをクリック
	1. URL Schemesを控えたConsumer Keyに置き換える
		- twitterkit-XXXXXXXXX
	1. 左のプロジェクトツリーからVendorInfo.swiftをクリック
		- TwitterCircle > TwitterCircle > Utility > VendorInfo.swift
	1. VendorInfo.swift内のメンバ変数の値をそれぞれお置き換える（Consumer Secretはリバースエンジニアリング対策で変換した値にする）
1. ビルド実行！