----------------------------------------------------------------------------------------
-- 狩人用 GearSwap スクリプト: ホバーショットの移動判定・高価な矢弾の外し忘れ防止・DistancePlus の自動切り替え
----------------------------------------------------------------------------------------

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
    set_language('japanese')
end

local res = require('resources')

-- ホバーショットの位置の記録用 (hovershot アドオンと同じ基準で判定する)
local last_shot_pos = nil       -- 前回、実際に撃ち終わった位置 {x, y}。nil なら次の1発目は判定しない
local last_shot_target = nil    -- 前回撃った敵の id (敵が変わったら層はリセット)
local hover_move_success = false

local function reset_hover_shot()
    last_shot_pos = nil
    last_shot_target = nil
end

-- 判定対象: 遠隔攻撃と、射撃(25)・弓術(26)の WS (近接 WS は対象外)
local function is_hover_shot_action(spell)
    if spell.action_type == 'Ranged Attack' then return true end
    if spell.type == 'WeaponSkill' then
        local ws = res.weapon_skills[spell.id]
        return ws ~= nil and (ws.skill == 25 or ws.skill == 26)
    end
    return false
end

local function has_hover_shot_buff()
    return buffactive['ホバーショット'] or buffactive['Hover Shot'] or buffactive[628]
end

function job_setup()
    state.Buff['ダブルショット'] = buffactive['ダブルショット'] or false
    state.IdleMode:options('Normal')
    state.OffenseMode:options('Normal','SubtleBlow','ACC')
    state.WeaponskillMode:options('Normal', 'SubtleBlow')
    state.RangedMode:options('Normal','Double','ACC')
    
    -- 武器の切り替え用の状態 (`gs c cycle MainWeapons` など。実際に持ち替える処理は user-globals.lua 側)
    state.MainWeapons  = M{'ネイグリング','ペルーン','マレヴォレンス','クラーケンクラブ'}
    state.SubWeapons   = M{'クラーケンクラブ','ヌスクシールド','クスタウィ+1'}
    state.RangeWeapons = M{'アナイアレイター','フォーマルハウト','ガーンデーヴァ','アルマゲドン','スパロウホーク'}
end

-- 遠隔攻撃のたびに全アイテム (数万件) を端から調べないよう、見つけた結果は名前ごとに覚える
-- (見つからなかった名前も覚える。装備を替えたときは別の名前になるだけなので、古い結果が間違うことはない)
local item_id_cache = {}
function get_item_id_by_name(name)
    if name == nil then return nil end
    local cached = item_id_cache[name]
    if cached ~= nil then return cached or nil end
    for id, item in pairs(res.items) do
        if item and item.name == name then
            item_id_cache[name] = id
            return id
        end
    end
    item_id_cache[name] = false
    return nil
end

-------------------------------------------------------------------
-- 遠隔攻撃の矢弾の自動選択 (銃・弓・クロスボウ)
-------------------------------------------------------------------
function job_post_pretarget(spell, action, spellMap, eventArgs)
    -- 高価なホクスボクアロー/ブレットを通常射撃で撃ってしまわないよう、装備中なら外す
    if (player.equipment.ammo == 'ホクスボクアロー' or player.equipment.ammo == 'ホクスボクブレット')
        and spell.name ~= 'サベッジブレード' and spell.name ~= 'イオリアンエッジ' then
        send_command('input /equip ammo')
    end

    if spell.action_type == 'Ranged Attack' then
        local range_item = player.equipment.range
        if range_item and gear then
            local item_id = get_item_id_by_name(range_item)
            if item_id and res.items[item_id] then
                local r_type = res.items[item_id].range_type
                if r_type == "Gun" and gear.GunPhysics then equip({ammo = gear.GunPhysics.name})
                elseif r_type == "Bow" and gear.BowPhysics then equip({ammo = gear.BowPhysics.name})
                elseif r_type == "Crossbow" and gear.CrossbowPhysics then equip({ammo = gear.CrossbowPhysics.name}) end
            end
        end
    elseif spell.name == 'サベッジブレード' and gear['ホクスボクアロー'] then
        equip({ammo=gear['ホクスボクアロー'].name})
    elseif spell.name == 'イオリアンエッジ' and gear['ホクスボクブレット'] then
        equip({ammo=gear['ホクスボクブレット'].name})
    end
end

-------------------------------------------------------------------
-- ホバーショット: 前回の位置から 1 Ym 以上動いたかを、撃つ直前に確かめる
-------------------------------------------------------------------
function job_precast(spell, action, spellMap, eventArgs)
    if not spell then return end

    -- 遠隔攻撃 (RA) または射撃・弓術 WS を撃つ直前の判定 (近接 WS は対象外)
    if is_hover_shot_action(spell) then
        -- 自分の今の座標を取得
        local p_mob = windower.ffxi.get_mob_by_target('me')

        -- ホバーショットのバフがあるときだけ判定する
        -- 前回の射撃位置が無い (ホバーショット直後・敵が変わった) ときは 1 発目なので判定しない
        local same_target = spell.target and spell.target.id == last_shot_target
        if p_mob and has_hover_shot_buff() and last_shot_pos and same_target then
            -- 前回の射撃位置からの直線距離 (Ym) を計算
            local dist = math.sqrt((p_mob.x - last_shot_pos.x)^2 + (p_mob.y - last_shot_pos.y)^2)

            if dist >= 1.0 then
                hover_move_success = true
                add_to_chat(6, '[Hover OK] 移動距離: ' .. string.format("%.2f", dist) .. ' Ym (スタックを維持して射撃)')
            else
                hover_move_success = false
                add_to_chat(123, '[Hover NG] 移動距離: ' .. string.format("%.2f", dist) .. ' Ym (1 Ym 未満のため射撃をキャンセルしました)')
                
                -- 1 Ym 動けていないときは、遠隔攻撃をキャンセルして層を守る
                eventArgs.cancel = true
                return
            end
        end
        -- 位置の記録は、実際に撃ち終わったとき (job_post_aftercast) に行う
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.action_type == 'Ranged Attack' then
        -- ダブルショットのバフがあるときは、専用の装備 (sets.buff) に替える
        if buffactive['ダブルショット'] or buffactive['Double Shot'] then
            if sets.buff and sets.buff['ダブルショット'] then
                equip(sets.buff['ダブルショット'])
            end
        end
    elseif spell.name == 'トゥルーフライト' or spell.name == 'イオリアンエッジ' then
        if get_hachirin then
            equip(get_hachirin(spell.element))
        end
    end
end

function job_post_aftercast(spell, action, spellMap, eventArgs)
    -- ホバーショット: 撃ち終わった位置と敵を、次回の比較用に記録する (中断・射程外などで撃てなかったときは記録しない)
    if spell.english == 'Hover Shot' then
        reset_hover_shot()                  -- 使い直すと層はリセット
    elseif is_hover_shot_action(spell) and not spell.interrupted then
        local p_mob = windower.ffxi.get_mob_by_target('me')
        if p_mob then
            last_shot_pos = {x = p_mob.x, y = p_mob.y}
            last_shot_target = spell.target and spell.target.id
        end
    end

    -- 近接 WS のあとは、高価な矢弾をすぐ外す
    if spell.name == 'サベッジブレード' or spell.name == 'イオリアンエッジ' then
        send_command('input /equip ammo')
    end
end

-- ホバーショットのバフが付いた・切れたときは層をリセット (hovershot アドオンと同じ)
function job_buff_change(buff, gain, eventArgs)
    if buff == 'ホバーショット' or buff == 'Hover Shot' then
        reset_hover_shot()
    end
end

-- エリアを移動したら層をリセット (GearSwap がジョブファイルの読み直し時に自動で解除する)
windower.register_event('zone change', function()
    reset_hover_shot()
end)

-------------------------------------------------------------------
-- 装備している遠隔武器・遠隔武器の切り替えに合わせた DistancePlus の自動切り替え (DistancePlus が必要)
-------------------------------------------------------------------
-- `gs c cycle RangeWeapons` で遠隔武器が変わった瞬間に、
-- DistancePlus の `//dp gun` / `//dp bow` を送る。
-- DistancePlus は `//dp gun` を受けるたびにチャットへ 5 行出す。装備・状態の更新のたびに送るとチャットが流れるので、
-- 直前に送った種別を覚えておき、変わったときだけ送る (GearSwap を読み込み直すと、また 1 回送る)
local last_dp_mode = nil
local function set_distanceplus(mode)
    if mode == last_dp_mode then return end
    last_dp_mode = mode
    windower.send_command('dp ' .. mode)
end

function job_state_change(stateField, newValue, oldValue)
    -- 遠隔武器 (RangeWeapons) の選択が変わったとき
    if stateField == 'Range Weapons' or stateField == 'RangeWeapons' then
        if newValue == 'アナイアレイター' or newValue == 'Annihilator' or newValue == 'フォーマルハウト' or newValue == 'アルマゲドン' then
            -- 銃の武器が選ばれたら gun に
            set_distanceplus('gun')
        elseif newValue == 'ガーンデーヴァ' or newValue == 'Gandiva' then
            -- 弓の武器が選ばれたら bow に
            set_distanceplus('bow')
        end
    end

    -- user-globals.lua に user_state_change があれば、それも呼ぶ
    if user_state_change then
        user_state_change(stateField, newValue, oldValue)
    end
end

-- 装備・状態が更新されたときにも、装備中の遠隔武器から確かめる
function job_update(cmdParams, eventArgs)
    if not player or not player.equipment then return end
    local ranged_weapon = player.equipment.range
    
    if ranged_weapon then
        if ranged_weapon == 'アナイアレイター' or ranged_weapon == 'Annihilator' or ranged_weapon == 'フォーマルハウト' or ranged_weapon == 'アルマゲドン' then
            set_distanceplus('gun')
        elseif ranged_weapon == 'ガーンデーヴァ' or ranged_weapon == 'Gandiva' then
            set_distanceplus('bow')
        end
    end
end
