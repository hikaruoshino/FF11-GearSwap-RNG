# FF11-GearSwap-RNG (v1.0)

FF11 狩人 (Ranger) 用の GearSwap ジョブファイルです。ホバーショットの移動判定、高価な矢弾の入れ替え、DistancePlus の自動切り替えをします。日本語クライアント用です。英語クライアント用は [FF11-GearSwap-RNG-EN](https://github.com/hikaruoshino/FF11-GearSwap-RNG-EN) にあります。

> **自己責任でお使いください。** FFXI の利用規約はサードパーティ製ツールを禁止しており、Windower や GearSwap もその対象になりえます。アカウントの停止などの不利益を受ける可能性があり、作者は責任を負いません。
> このファイルは、あなたの代わりにウェポンスキルや魔法を使うことはありません。装備を替え、条件を満たさない遠隔攻撃をキャンセルし、DistancePlus へコマンドを送るだけです。

## 何をするか

1. **ホバーショットの移動判定**
   - ホバーショットのバフがあるとき、前回撃った位置から 1 Ym 以上動いていなければ、遠隔攻撃・射撃/弓術のウェポンスキルをキャンセルします。層 (ホバーショットの重なり) を保つための確認です。
   - 前回の位置が無いとき (ホバーショットを使った直後・敵が変わったとき) は 1 発目なので、判定しません。
   - 判定の結果は、チャットに `[Hover OK]` / `[Hover NG]` と動いた距離で出ます。
   - 位置は、実際に撃ち終わったときに記録します。中断・射程外のときは記録しません。
   - ホバーショットの使い直し、バフが付いた・切れたとき、エリア移動で、記録をリセットします。
2. **高価な矢弾の入れ替え**
   - 遠隔攻撃のとき、持っている遠隔武器の種類 (銃・弓・クロスボウ) に合わせて、通常の矢弾 (`gear.GunPhysics` など) を装備します。
   - サベッジブレードの前にホクスボクアローを、イオリアンエッジの前にホクスボクブレットを装備し、ウェポンスキルのあとに外します。
   - ホクスボクアロー/ブレットが装備されたままのときは、行動の前に外します (通常の遠隔攻撃で使ってしまわないため)。
3. **ダブルショット**: ダブルショットのバフがあるときの遠隔攻撃は、`sets.buff['ダブルショット']` に替えます。
4. **DistancePlus の自動切り替え (DistancePlus が必要です)**
   - `gs c cycle RangeWeapons` で遠隔武器を替えたとき、またはその武器を装備した状態で戦闘状態やバフが変わったとき (`//gs c update` でも) に、DistancePlus へ `//dp gun` / `//dp bow` を送ります。銃 = アナイアレイター・フォーマルハウト・アルマゲドン、弓 = ガーンデーヴァ。
   - DistancePlus は `//dp gun` を受けるたびにチャットへ 5 行出すので、直前に送った種別を覚えておき、変わったときだけ送ります。
   - スパロウホークは弓ですが、サベッジブレード用に持つ武器なので、DistancePlus は切り替えません (直前の gun / bow のままです)。
   - クロスボウ用の `//dp xbow` への切り替えは入れていません (矢弾の自動選択はクロスボウにも対応しています)。
5. **属性帯**: トゥルーフライト・イオリアンエッジの装備に、`get_hachirin` があれば天候・曜日の帯を足します (user-globals.lua の関数。無ければ何もしません)。

## 必要なもの

| 必要なもの | 備考 |
| :--- | :--- |
| Windower 4 と GearSwap | Windower に付属の GearSwap (Mote-Include) |
| **DistancePlus (要インストール)** | 4 の自動切り替えに必要です。Windower の公式アドオン一覧に入っています。入れていないと、`//dp` が届かず、距離の表示の切り替えは動きません。それ以外の機能は動きます |
| 日本語クライアント | ファイル内の名前が日本語です |
| `user-globals.lua` (任意) | 次の節をお読みください |

DistancePlus は読み込んでおいてください (`//lua load distanceplus`、自動で読み込むなら `init.txt` に `lua l distanceplus`)。

## user-globals.lua について

武器の切り替え (`gs c cycle MainWeapons` など)、ロックスタイル、共通のウェポンスキル定義 (`init_weapon_skill`)、属性帯 (`get_hachirin`) は、[greeds.net のコード一覧](https://greeds.net/gearswap-code-list/) ([ktgreeds/GearSwap](https://github.com/ktgreeds/GearSwap)) にある `user-globals.lua` と一緒に使う前提で作ってあります。このファイルは greeds さんのもので、ライセンスの記載がなく、再配布の許諾は明示されていません。**このリポジトリには、このファイルも、その改変も入れていません。**

なくても動きます。`RNG_gear.lua` の `init_ranger_weapon_skills` が、遠隔ウェポンスキルの装備セットの最小の表を持っていて、`init_weapon_skill` が無いときはそちらを使います。ただし、`gs c cycle MainWeapons` などの武器の切り替えは、user-globals.lua が無いと働きません。

## ファイルとインストール

```text
Windower4/addons/GearSwap/data/
├── RNG.lua                  <-- ロジック本体
└── <キャラクター名>/
    └── RNG_gear.lua         <-- 装備セット (自分の装備に書き換える)
```

1. このリポジトリをダウンロード (Code > Download ZIP) して展開します。
2. `RNG.lua` を `Windower4/addons/GearSwap/data/` に置きます。
3. `RNG_gear.lua` を `Windower4/addons/GearSwap/data/<キャラクター名>/` に置き、**自分の持っている装備に書き換えます。** 中身は作者の装備です。
4. 狩人でログインし、`//gs reload` (または `//gs load RNG`) を実行します。

## 装備ファイル (RNG_gear.lua)

| 設定 | 使われるとき |
| :--- | :--- |
| `gear['武器名']` | 武器の切り替えで使う装備の定義。`RNG.lua` の `state.MainWeapons` / `SubWeapons` / `RangeWeapons` の名前と合わせます |
| `gear.GunPhysics` / `BowPhysics` / `CrossbowPhysics` | 遠隔攻撃のときに装備する通常の矢弾 |
| `gear['ホクスボクアロー']` / `gear['ホクスボクブレット']` | サベッジブレード / イオリアンエッジの前に装備する矢弾 |
| `sets.precast.RA` / `sets.midcast.RA` (`.Double` / `.ACC`) | スナップショット / 遠隔攻撃 |
| `sets.buff['ダブルショット']` | ダブルショットのバフがあるときの遠隔攻撃 |
| `sets.precast.WS.Damage` / `.Range` / `.Magic` と、ウェポンスキルごとのセット | ウェポンスキル |
| `sets.idle` / `sets.engaged` ほか | 通常の装備 |

## ゲーム内での確認の範囲

* DistancePlus の自動切り替え (切り替えと、チャットが流れないこと) は、2026-10-24 にゲーム内で確認しました。
* ホバーショットの判定と矢弾の入れ替えは、公開用に整理したこの版を、ゲーム内ではまだ試していません。模擬環境のテストは通っています。
* 近接ウェポンスキル (サベッジブレード・イオリアンエッジ) を続けて撃つときの矢弾の入れ替えは、ゲーム内で確認していません。
* 同梱の `RNG_gear.lua` は作者の装備のまま (装備の名前は作者の持ち物) です。

うまく動かないときは、コンソールのメッセージを添えて Issues でお知らせください。

## 出典とライセンス

このジョブファイルの土台 (ファイルの構成・装備ファイルの書き方・武器の切り替えの考え方) は、greeds さんのコード ([greeds.net](https://greeds.net/gearswap-code-list/)、[ktgreeds/GearSwap](https://github.com/ktgreeds/GearSwap)) を参考に、改変・作り直したものです。ホバーショットの判定の基準は、hovershot アドオンに合わせています。ライセンスは付けていません。元のコードの権利は元の作者にあります。問題があれば、お知らせください。取り下げます。

## 更新履歴

* v1.0: 公開。DistancePlus は、遠隔武器が変わったときだけコマンドを送る
