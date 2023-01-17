require "string"
require "table"
function letter(w)
    local l = {}
    local letters = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
                     "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
    local capletters = {"!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "A", "B", "C", "D", "E", "F", "G", "H", "I",
                        "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "x", "Y", "Z"}
    for i = 1, 36 do
        if w.pressed(letters[i]) == 1 then
            if w.held("lshift") == 1 then
                table.insert(l, capletters[i])
            else
                table.insert(l, letters[i])
            end
        end
    end
    return l
end
function runedit(w)
    clicks = sound("menuclick.wav")
    enters = sound("menuenter.wav")
    clicks.volume, enters.volume = 0.3, 0.3
    editstring = ""
    while true do
        w.loop()
        local ll = letter(w)
        if ll[1] ~= nil then
            speak(ll[1])
            editstring = editstring .. ll[1]
            clicks.set_position(0)
            clicks.play()
        end
        if w.pressed("enter") == 1 then
            enters.play()
            return editstring
        end
        if w.pressed("space") == 1 then
            speak("")
            clicks.set_position(0)
            clicks.play()
            editstring = editstring .. " "
        end
        if w.pressed("left") == 1 or w.pressed("right") == 1 or w.pressed("up") == 1 or w.pressed("down") == 1 then
            speak(editstring)
        end
        if w.pressed("backspace") == 1 and len(editstring) > 0 then
            speak(string.sub(editstring, len(editstring), len(editstring)))
            editstring = string.sub(editstring, 1, string.len(editstring) - 1)
            clicks.set_position(0)
            clicks.play()
        end
        check_for_music_volumes(w)
    end
end

function runmenu(w, mlist, pos)
    if pos == nil then
        pos = 0
    end
    clicksound = sound("menuclick.wav")
    entersound = sound("menuenter.wav")
    entersound.volume = 0.3
    clicksound.volume = 0.3
    local i = pos
    local multitimer = 0
    local multistring = ""
    local t = 0
    local did = false
    while true do
        w.loop()
        if multistring ~= "" and elapsed() - multitimer >= 0.25 then
            multistring = ""
        end
        local l = letter(w)
        if l[1] ~= nil then
            multistring = multistring .. l[1]
            multitimer = elapsed()
            if string.len(multistring) > 1 and string.find(mlist[pos], multistring) == 1 then
            else

                t = 0
                i = pos
                did = false
                repeat
                    t = t + 1
                    i = i + 1
                    if i > len(mlist) then
                        i = 0
                    end
                    if i ~= 0 then
                        if string.find(mlist[i], multistring) == 1 and did ~= true then
                            did = true
                            pos = i
                            clicksound.set_position(0)
                            clicksound.play()
                            speak(mlist[pos])
                        end
                    end
                until t >= len(mlist)
            end
        end
        if w.pressed("end") == 1 then
            pos = len(mlist)
            clicksound.set_position(0)
            clicksound.play()
            speak(mlist[pos])
        end
        if w.pressed("home") == 1 then
            pos = 1
            clicksound.set_position(0)
            clicksound.play()
            speak(mlist[pos])
        end
        if w.pressed("down") == 1 and pos < len(mlist) then
            pos = pos + 1
            clicksound.set_position(0)
            clicksound.play()
            speak(mlist[pos])
        end
        if w.pressed("up") == 1 and pos > 1 then
            pos = pos - 1
            clicksound.set_position(0)
            clicksound.play()
            speak(mlist[pos])
        end
        if w.pressed("enter") == 1 and pos > 0 then
            entersound.play()
            return pos
        end
        check_for_music_volumes(w)
    end
end
