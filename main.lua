require "math"
require "table"
--first, I will implement some code I found
function GetRandomString(tbl)
  local keys = {}
  for x,y in pairs(tbl) do
    table.insert(keys, x)
  end
  local randomIndex = keys[math.random(#keys)]
  return randomIndex
end


function fix_array(inputarray)
outputarray={}
for i,j in pairs(inputarray) do
table.insert(outputarray,j)
end
return outputarray
end
function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
function main()
--requirements
require "os"
require "io"
require "math"
--don't require math and table here, already did it for other code

require "string"
changedir("./projects/xbs-3")
json=require "json"
math.randomseed(os.time())
dofile("ui.lua")
dofile("mus.lua")
--metadatas variables
version="0.1.1"
--core functions
--we don't want the normal wait, it's slow and don't support our game loops that we need
wait=nil
function wait(timetowait,extra)
timetowait=timetowait/1000
local e=elapsed()
repeat
w.loop()
if extra~=nil then
local ex=extra()
if ex=="skip" then return end
end
check_for_music_volumes(w)
until elapsed()-e>timetowait
end
--the fighter class
fighter={health=50,speed=100,name="unnamed",attack=0,defence=0,moves={}}
--here come the various move scripts. Since there are so many of them and due to the way they are organized, I have sorted them into various files (mv_xxx.lua)
moves={}
turn_start_triggers={}
turn_end_triggers={}
prefire_triggers={}
postfire_triggers={}
dofile("mv_basics.lua")
--two tables: the roster are all the currently available fighters, and can be saved and returned.. The fighters, on the other hand, are something that is curently in play.
playfield={}
roster={}
f=io.open("roster.json","r")
if f~=nil then
file=f:read("*a")
if file~=nil then
roster=json.decode(file)
speak(""..#roster.." fighter(s) loaded from your json file")
end
f:close()
end
--fighter's manipulation functions
--this function creates a new fighter and returns it's table object. Then, it can be placed either in the fighters or roster tables, or in a completely other table if you like for custom moves and scripts.
function newfighter(o) 
if o==nil then 
o={health=50,speed=100,name="unnamed",moves={},attack=0,defence=0,team="unset",control="ai"} 
end 
setmetatable(o,{__index=fighter}) 
return o 
end
--this here function is for a user interface which help with modification of fighters.
function movemenu(w,m)
speak("Check and uncheck the moves to set up your preferred move list.")
lastmenuposition=nil
while true do
mvm={}
mvmn={}
for i,j in pairs(moves) do
checked="Unchecked"
if m.moves[j.name]~=nil then
checked="Checked"
end
mvm[#mvm+1]=j.name..". "..checked
mvmn[#mvm]=j.name
end
mvm[#mvm+1]="finished"
lastmenuposition=runmenu(w,mvm,lastmenuposition)
if lastmenuposition==#mvm then
speak("Done")
return
end
if m.moves[mvmn[lastmenuposition]]==nil then
m.moves[mvmn[lastmenuposition]]=true
speak("Checked.")
else
m.moves[mvmn[lastmenuposition]]=nil
speak("Unchecked.")
end
end
end
function modfighter(w,m,parent,index)
speak("Variable modifier. Please select something to modify.")
while true do
mv=""
for i,j in pairs(m.moves) do
mv=mv..i..". "
end
local varmod=runmenu(w,{"name: "..m.name,"health: "..m.health,"speed: "..m.speed,"attack: "..m.attack,"defence: "..m.defence,"team: "..m.team,"moves: "..mv,"controller: "..m.control,"remove fighter","finished"})
if varmod==1 then
speak("Please enter the name of this fighter, for example, the mighty warrior. Spaces are allowed.")
m.name=runedit(w)
if m.team=="unset" then m.team=m.name.."'s team" end
end
if varmod==2 then
speak("Please enter the health of this fighter, or the amount of hit points it should have. This value should be a number above 0, and we recommend between 10 and 300 points.")
m.health=tonumber(runedit(w))
end
if varmod==3 then
speak("Please enter the speed for this fighter. It should be above 0 and we recommend a value between 50 and 100. The speed value controls how likely it is that the fighter will take initiative")
m.speed=tonumber(runedit(w))
end
if varmod==4 then
speak("Please enter the attack value for this fighter. It should be a number that calculates the amount of damage added onto attacks. We recommend a value between -15 and 15, but your safest bet is 0.")
m.attack=tonumber(runedit(w))
end
if varmod==5 then
speak("Please enter the defence value for this fighter. It should be a number that calculates the amount of damage removed from incoming attacks. We recommend a value between -15 and 15, but your safest bet is 0.")
m.defence=tonumber(runedit(w))
end
if varmod==6 then
speak("Please enter the team of a fighter. For example: the warrior's alliance.")
m.team=runedit(w)
end
if varmod==9 then
if parent==nil then
speak("You can't delete this fighter, as it is not in any parent field (roster or playfield for instance)")
else
table.remove(parent,index)
speak("Done!")
return--no more fighter, ref is nil. Errors if we continue!
end
end
if varmod==7 then
movemenu(w,m)
end
if varmod==8 then
opt={"human","ai"}
speak("Select one of these two options")
m.control=opt[runmenu(w,opt)]
end
if varmod==10 then
if m.name=="unnamed" or len(m.moves)~=0 then speak("Sorry, but this fighter is not yet finished! If you made one by mistake or deleted all the moves, you need to add more.") else speak("Done!") return end
end
end
end
--implementation of the smart-sound system that caches sounds in memory. When they are no longer in use, the game takes them back and re-uses them. Cool, huh?
smartsounds={}
function play(soundname,soundvol,soundpan)
if soundvol==nil then soundvol=50 end
if soundpan==nil then soundpan=0 end
--these are because I'm used to PureBasic's way of handling sounds.
soundvol=soundvol/100
soundpan=soundpan/100
spos=#smartsounds+1
for i,j in pairs(smartsounds) do
if j.name==soundname and j.stream.is_playing~=true then
spos=i
end
end
if spos==#smartsounds+1 then
smartsounds[spos]={name=soundname,stream=sound(soundname)}
end
smartsounds[spos].stream.volume=soundvol
smartsounds[spos].stream.pan=soundpan
smartsounds[spos].stream.play()
end
--in-game functions
--function to change stats of the fighters
function stat(person,stat,amount,defaultamount)
if defaultamount==nil then defaultamount=0 end
if person[stat]==nil then person[stat]=defaultamount end
person[stat]=person[stat]+amount
if amount>0 then
speak(person.name.."'s "..stat.." increases by "..amount)
play("xsound/statup.ogg",50,0)
wait(1300)
end
if amount<0 then
speak(person.name.."'s "..stat.." decreases by "..tostring(-amount))
play("xsound/statdown.ogg",50,0)
wait(1100)
end
end
--function to calculate damage and returns it, speaking damage output
function damage(dam)
dam=dam+attacker.attack
dam=dam-target.defence
if dam<0 then dam=0 end
target.lastdamage=dam
target.health=target.health-dam
speak(target.name.." took "..dam.." damage!")
return dam
end
--menu functions
function extras()
speak("Extras menu. Please select an option.")
command=runmenu(w,{"update the game","back"})
if command==1 then
speak("By updating, you will lose any unsaved changes you've made, so make sure any moves and sounds you've added are backed up before you update to the new version of the game. If you're ready to update, click continue, otherwise click cancel.")
if runmenu(w,{"continue","cancel"})==1 then
speak("getting ready for update...")
os.execute("git stash")
os.execute("git stash drop")
speak("Checking server for updates...")
os.execute("git fetch")
speak("Updating the game, please wait...")
os.execute("git pull")
speak("Game updated successfully! Please restart the program for it to take effect.")
end
end
end
function modmenu(w,m)
while true do
speak("Select a fighter to modify.")
mm={}
for i,j in pairs(m) do
table.insert(mm,j.name)
end
table.insert(mm,"new...")
table.insert(mm,"finished")
local mf=runmenu(w,mm)
if mf==#m+2 then
f=io.open("roster.json","w")
f:write(json.encode(roster))
f:close()
speak("Roster saved!")
return
end
if mf==#m+1 then
nf=newfighter()
table.insert(m,deepcopy(nf))
modfighter(w,m[#m],roster,#m)
end
if mf<#m+1 then
modfighter(w,m[mf],roster,r)
end
end
end
function fight()
playfield={}
speak("Please select fighters from the roster to add to the playfield")
addto={}
for i,j in pairs(roster) do
table.insert(addto,j.name)
end
table.insert(addto,"done")

while true do
adding=runmenu(w,addto,0)
if adding==#addto then
speak("All done!")
break
end
table.insert(playfield,deepcopy(roster[adding]))
speak("Added")
end
speak("Now you can modify the playfield however you like.")
modmenu(w,playfield)
--initialize temp vars that would be useless to save
for i,j in pairs(playfield) do
j.didnt_play=0
end
speak("Select a mode")
modes={"classic mode","cancel fight and return to menu"}
mode=runmenu(w,modes)
if #playfield==0 then
speak("You do not have any fighters. Cancelling.")
return
end
if mode==#modes then
speak("canceled")
return
end
if mode==1 then
if #playfield==1 then
speak("You only have 1 fighter. Classic mode needs at least 2. Cancelled.")
return
end
st=playfield[1].team
for i,j in ipairs(playfield) do
if j.team~=st then
changed=true
end
end
if changed==nil then
speak("All of your fighters are on the same team, and thus the fight can't start. Cancelled.")
return
end
end
music("fightmus.ogg")
speak("Prepare for combat!")
wait(1500)
speak("Fight!")
wait(1500)
turn=0
while true do
turn=turn+1
speak("Turn "..turn)
play("xsound/turn.ogg",50,0)
wait(1300)
play("xsound/initiative.ogg",50,0)
bestspeed=0
for i,j in pairs(playfield) do
j.didnt_play=j.didnt_play+1
sr=math.random(1,j.speed)
--if this fighter hasn't played recently, give them a bonus to their speed
sr=sr+j.didnt_play*8
if sr>bestspeed then
attacker=j
bestspeed=sr
end
end
attacker.didnt_play=0
speak(attacker.name.." has taken the initiative!")
for i,j in pairs(turn_start_triggers) do
j(attacker)
end
wait(1300)
move=""
if attacker.control == "ai" then
move=GetRandomString(attacker.moves)
else
speak("select a move")
ml={}
for i,j in pairs(attacker.moves) do
table.insert(ml,i)
end
move=ml[runmenu(w,ml)]
end
--convert this into it's true move form (ref)
move=moves[move]
if move.secret==true then
speak(attacker.name.." used a secret move!")
else
speak(attacker.name.." used "..move.name.."!")
end
if move.sound==nil then play("xsound/play.ogg") else play(move.sound) end
--reset target var because we have a new move now
target=nil
if move.offensive~=nil then
if attacker.control=="ai" then
--simple for now replace with something else if you like
repeat
target=playfield[math.random(1,#playfield)]
until target.team~=attacker.team
else
speak("Select a target")
ml={}
for i,j in pairs(playfield) do
if j.team~=attacker.team then
table.insert(ml,j)
end
end
ml2={}
for i,j in ipairs(ml) do
table.insert(ml2,j.name)
end
target=ml[runmenu(w,ml2)]
end
end
trig=nil
for i,j in pairs(prefire_triggers) do
if j(move,attacker,target)==true then trig=true end
end
if trig==nil then if target~=nil then move.play(attacker,target) else move.play(attacker) end end
for i,j in pairs(postfire_triggers) do
j(move,attacker,target)

end
wait(600)
for i,j in pairs(turn_end_triggers ) do
j(attacker)
end
--check for defeated fighters
for i,j in pairs(playfield) do
if j.health<1 then
speak(j.name.." has been defeated and is out!")
--can't kill the fighter from ref (will reassign ref var). You have to do it directly
playfield[i]=nil

end
end
playfield=fix_array(playfield)
sameteam=playfield[1].team
over=1
for i,j in pairs(playfield) do
if j.team~=sameteam then over=0 end
end
if over==1 then
speak("And the winner of the fight is...")
wait(2500)
if #playfield==1 then
speak(playfield[1].name.."!")
else
speak(playfield[1].team.."!")
end
wait(1500)
return
end
end
end
function mainmenu()
music("menumus.ogg")
speak("Main menu. Please select an option.")
return runmenu(w,{"set","play","extras","exit"})
end
--initializing main code goes here
w=newwindow("xtreme battle simulator 3 version "..version)
logo=sound("xtreme games.ogg")
logo.play()
wait(12500,function()
if w.pressed("enter")==1 then
for fade=1,0.01,-0.01 do
logo.volume=fade
wait(5)
end
logo.stop()
return "skip"
end
end
)
while true do
r=mainmenu()
if r==1 then modmenu(w,roster) end
if r==2 then fight() end
if r==3 then extras() end
if r==4 then speak("Are you sure you want to exit the game?") if runmenu(w,{"yes","no"})==1 then speak("thanks for playing!") wait(1000) mus.free() return 4 end end
end
end
main()
