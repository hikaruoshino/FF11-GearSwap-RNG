-- user-globals.lua があるときに、そちらから呼ばれる (初期の武器の設定)
function init_weaponns()
    -- 初期の武器を設定
    send_command('gs c set MainWeapons '..windower.to_shift_jis('ペルーン'))
    if player.sub_job == '忍' or player.sub_job == 'NIN' or player.sub_job == '踊' or player.sub_job == 'DNC' then
        send_command('wait 1; gs c set SubWeapons '..windower.to_shift_jis('クラーケンクラブ'))
    else
        send_command('wait 1; gs c set SubWeapons '..windower.to_shift_jis('ヌスクシールド'))
    end

end


-- user-globals.lua が無い環境用: 遠隔 WS をどの装備セットで撃つかの最小の表。
-- (user-globals.lua に init_weapon_skill があるときは、そちらが使われる)
function init_ranger_weapon_skills()
    local ranged = {
        'フレイミングアロー', 'ピアシングアロー', 'ダリングアロー', 'サイドワインダー', 'ブラストアロー', 'アーチングアロー',
        'エンピリアルアロー', '南無八幡', 'リフルジェントアロー', 'エイペクスアロー', 'シャルヴ',
        'ホットショット', 'スプリットショット', 'スナイパーショット', 'スラッグショット', 'ブラストショット', 'ヘヴィショット',
        'デトネーター', 'ナビングショット', 'ラストスタンド', 'ジ・エンド',
    }
    local magic = {'トゥルーフライト', 'ワイルドファイア', 'レデンサリュート', 'イオリアンエッジ'}
    for _, name in ipairs(ranged) do sets.precast.WS[name] = sets.precast.WS.Range end
    for _, name in ipairs(magic) do sets.precast.WS[name] = sets.precast.WS.Magic end
end


function init_gear_sets()
    -- ロックスタイルの番号
    lockstyleset = 107

    -- 武器
    gear['ネイグリング']        = {name="ネイグリング"}
    gear['クスタウィ+1']        = {name="クスタウィ+1"}
    gear['クラーケンクラブ']    = {name="クラーケンクラブ"}
    gear['マレヴォレンス']      = {name="マレヴォレンス"}
    gear['ペルーン']            = {name="ペルーン+1"}
    gear['ヌスクシールド']      = {name="ヌスクシールド"}
    gear['アルマゲドン']        = {name="アルマゲドン"}
    gear['フォーマルハウト']    = {name="フォーマルハウト"}
    gear['スパロウホーク']      = {name="スパロウホーク+2"}
    gear['アナイアレイター']    = {name="アナイアレイター"}
    gear['ガーンデーヴァ']      = {name="ガーンデーヴァ"}
    gear['プライムガン']        = {name="プライムガン"}
    gear['ホクスボクアロー']    = {name="ホクスボクアロー"}
    gear['ホクスボクブレット']  = {name="ホクスボクブレット"}
    gear.GunPhysics             = {name="クロノブレット"}
    gear.GunMagical             = {name="クロノブレット"}
    gear.BowPhysics             = {name="アルテミスの矢"}
    gear.BowMagical             = {name="アルテミスの矢"}
    gear.CrossbowPhysics        = {name="ブロンズボルト"}
    gear.CrossbowMagical        = {name="ブロンズボルト"}

    -- 待機装備 (通常)
    sets.idle = {
    head="ニャメヘルム",
    body="ニャメメイル",
    hands="ニャメガントレ",
    legs="ニャメフランチャ",
    feet="ニャメソルレット",
        neck="無の喉輪",
        waist="無の腰当",
    left_ear="エアバニピアス",
    right_ear="エテオレートピアス",
    left_ring="守りの指輪",
    right_ring="シュネデックリング",
        back="無の外装",
    }

    -- 待機装備 (リフレッシュ)
    sets.idle.Refresh = set_combine(sets.idle,{
        neck="シビルスカーフ",
    })

    -- 抜刀時の装備
    sets.engaged = {
        head="マリグナスシャポー",
        body="マリグナスタバード",
        hands="ＡＭグロブレト+2",
        legs="ＡＭブラーグ+3",
        feet="マリグナスブーツ",
        neck="無の喉輪",
        waist={ name="セールフィベルト+1", augments={'Path: A',}},
        left_ear="昏黄の耳飾り",
        right_ear="アスプロピアス",
        left_ring="シーリチリング+1",
        right_ring="シーリチリング+1",
        back="無の外装",
    }

    -- モクシャ 50
    sets.engaged.SubtleBlow = set_combine(sets.engaged,{
        head="ダンペニングタム",
        hands={ name="アデマリスト+1", augments={'Accuracy+20','Attack+20','"Subtle Blow"+8',}},
        feet="ムンムゲマッシュ+2",
        waist={ name="セールフィベルト+1", augments={'Path: A',}},
        right_ear="ディグニタリピアス",
        left_ring="シーリチリング+1",
        right_ring="シーリチリング+1",
    })

    -- 二刀流 11 (サポ忍)
    sets.engaged.dual11= {waist="霊亀腰帯",left_ear="エアバニピアス",}
    
    -- 二刀流 21 (サポ踊)
    sets.engaged.dual21= set_combine(sets.engaged.dual11,{back={ name="カムラスマント", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dual Wield"+10','Phys. dmg. taken-10%',}},})

    -- バフがあるときの装備
    sets.buff['ダブルショット']       = set_combine(sets.midcast.RA,{
    head="ＡＭガペット+2",
    body="ＡＲジャーキン+4",
    hands="オショシグローブ+1",
    legs="オショシトラウザ+1",
    feet="オショシレギンス+1",
    neck={ name="スカウトゴルゲ+2", augments={'Path: A',}},
    waist="イェマヤベルト",
    left_ear="デディションピアス",
    right_ear="テロスピアス",
    left_ring="カコエシクリング+1",
    right_ring="昏黄の指輪",
    back={ name="ベレナスケープ", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','"Store TP"+10',}},
        })

    --FC
    sets.precast.FC = {
        hands="レイライングローブ",
        feet="カマイングリーヴ",
        neck="オルンミラトルク",
        waist="コーネリアの黒帯",
        left_ear="エテオレートピアス",
        right_ear="エンチャンピアス+1",
        left_ring="メランリング",
        right_ring="ラハブリング",
    }
    sets.precast.FC.value = 35

    -- スナップショット
    sets.precast.RA = {
    head={ name="テーオンシャポー", augments={'Accuracy+21','"Snapshot"+5','"Snapshot"+5',}},
    body="ＡＭカバン+3",
    hands="オショシグローブ+1",
    legs="ＯＲブラッカエ+3",
    feet="メガナダジャンボ+2",
    waist="イェマヤベルト",
    left_ring="昏黄の指輪",
    right_ring="守りの指輪",
    back={ name="ベレナスケープ", augments={'"Snapshot"+10',}},
    }

    -- WS (近接物理ダメージ)
    sets.precast.WS.Damage = {
    ammo="ホクスボクアロー",
    head="ニャメヘルム",
    body="ニャメメイル",
    hands="ニャメガントレ",
    legs="ニャメフランチャ",
    feet="ニャメソルレット",
    neck="共和プラチナ章",
    waist="セールフィベルト+1",
    left_ear="胡蝶のイヤリング",
    right_ear="アミニピアス+1",
    left_ring="王将の指輪",
    right_ring="シーリチリング+1",
    back={ name="ベレナスケープ", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%',}},
    }
    
    -- WS (遠隔物理ダメージ)
    sets.precast.WS.Range = {
    head="ＯＲベレー+4",
    body="ＡＭカバン+3",
    hands="マリグナスグローブ",
    legs="ＡＲブラッカエ+4",
    feet="ＡＭボティヨン+3",
    neck={ name="スカウトゴルゲ+2", augments={'Path: A',}},
    waist="フォシャベルト",
    left_ear="イシュヴァラピアス",
    right_ear={ name="アミニピアス+1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Crit.hit rate+4',}},
    left_ring="王将の指輪",
    right_ring="コーネリアリング",
    back={ name="ベレナスケープ", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%',}},
    }
    
    -- WS (遠隔魔法攻撃)
    sets.precast.WS.Magic = {
        head="ニャメヘルム",
        body="ニャメメイル",
        hands="ニャメガントレ",
        legs="ニャメフランチャ",
        feet="ニャメソルレット",
        neck={ name="コモドアチャーム+2", augments={'Path: A',}},
        waist="オルペウスサッシュ",
        left_ear={ name="胡蝶のイヤリング", augments={'Accuracy+4','TP Bonus +250',}},
        right_ear="フリオミシピアス",
        left_ring="ディンジルリング",
        right_ring="エパミノダスリング",
        back={ name="ベレナスケープ", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%',}},
    }

    -- WS (モクシャ)
    sets.precast.WS.SubtleBlow = sets.engaged.SubtleBlow
    
    -- 共通の WS の定義 (user-globals.lua に init_weapon_skill があればそれを使い、無ければ下の最小の表を使う)
    if init_weapon_skill then
        init_weapon_skill()
    else
        init_ranger_weapon_skills()
    end

    -- WS ごとの装備
    sets.precast.WS["カラナック"] = set_combine(sets.precast.WS.Range,{
    head="ＯＲベレー+4",
    body="ＡＭカバン+3",
    hands="ＡＭグロブレト+2",
    legs="ＡＲブラッカエ+4",
    feet="ＡＭボティヨン+3",
    neck={ name="スカウトゴルゲ+2", augments={'Path: A',}},
    waist="フォシャベルト",
    left_ear="ドミネンスピアス+1",
    right_ear={ name="アミニピアス+1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Crit.hit rate+4',}},
    left_ring="王将の指輪",
    right_ring="カコエシクリング+1",
    back={ name="ベレナスケープ", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%',}},
    })

    sets.precast.WS["ジシュヌの光輝"] = set_combine(sets.precast.WS.Range,{
    ammo="アルテミスの矢",
    head="ブリスタサリット+1",
    body="イケンガベスト",
    hands="ンザメブレーサー",
    legs="ＡＭブラーグ+3",
    feet="イケンガクロッグ",
    neck="フォシャゴルゲット",
    waist="フォシャベルト",
    left_ear="オドルピアス",
    right_ear={ name="アミニピアス+1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Crit.hit rate+4',}},
    left_ring="王将の指輪",
    right_ring="イラブラットリング",
    back={ name="ベレナスケープ", augments={'DEX+20','Rng.Acc.+20 Rng.Atk.+20','DEX+10','Crit.hit rate+10','Damage taken-5%',}},
    })

    sets.precast.WS["サベッジブレード"] = set_combine(sets.precast.WS.Damage,
   {
    range="スパロウホーク+2",
    ammo="ホクスボクアロー",
    head="ニャメヘルム",
    body="ニャメメイル",
    hands="ニャメガントレ",
    legs="ニャメフランチャ",
    feet="ニャメソルレット",
    neck="共和プラチナ章",
    waist="セールフィベルト+1",
    left_ear="胡蝶のイヤリング",
    right_ear={ name="アミニピアス+1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Crit.hit rate+4',}},
    left_ring="王将の指輪",
    right_ring="コーネリアリング",
    back="無の外装",
   })

    -- 遠隔攻撃
    sets.midcast.RA = {
    head="ＡＲベレー+4",
    body="イケンガベスト",
    hands="イケンガグローブ",
    legs="ＡＭブラーグ+3",
    feet="イケンガクロッグ",
    neck={ name="スカウトゴルゲ+2", augments={'Path: A',}},
    waist="イェマヤベルト",
    left_ear="デディションピアス",
    right_ear="テロスピアス",
    left_ring="昏黄の指輪",
    right_ring="シーリチリング+1",
    back={ name="ベレナスケープ", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','"Store TP"+10',}},
    }

    -- 遠隔攻撃
    sets.midcast.RA.Double = {
    head="ＡＭガペット+2",
    body="ＡＲジャーキン+4",
    hands="オショシグローブ+1",
    legs="オショシトラウザ+1",
    feet="オショシレギンス+1",
    neck={ name="スカウトゴルゲ+2", augments={'Path: A',}},
    waist="イェマヤベルト",
    left_ear="デディションピアス",
    right_ear="テロスピアス",
    left_ring="カコエシクリング+1",
    right_ring="昏黄の指輪",
    back={ name="ベレナスケープ", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','"Store TP"+10',}},
    }

    -- 遠隔攻撃
    sets.midcast.RA.ACC = {
    head="マリグナスシャポー",
    body="ＡＭカバン+3",
    hands="ＡＭグロブレト+2",
    legs="ＡＭブラーグ+3",
    feet="ＡＭボティヨン+3",
    neck="無の喉輪",
    waist="イェマヤベルト",
    left_ear="テロスピアス",
    right_ear={ name="アミニピアス+1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Crit.hit rate+4',}},
    left_ring="カコエシクリング+1",
    right_ring="昏黄の指輪",
    back={ name="ベレナスケープ", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','"Store TP"+10',}},
    }
end
