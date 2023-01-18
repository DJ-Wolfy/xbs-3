--first, I will implement some code I found
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
require "table"
require "string"
changedir("./projects/xbs-3")
json=require "json"
dofile("ui.lua")
dofile("mus.lua")
--metadatas variables
version="0.1"
--the fighter class
fighter={health=50,speed=100,name="unnamed",attack=0,defence=0,moves={}}
--here come the various move scripts. Since there are so many of them and due to the way they are organized, I have sorted them into various files (mv_xxx.lua)
moves={}
dofile("mv_basics.lua")
--two tables: the roster are all the currently available fighters, and can be saved and returned.. The fighters, on the other hand, are something that is curently in play.
fighters={}
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
mvm[#mvm+1]="done"
lastm=runmenu(w,mvm,lastm)
if lastm==#mvm then
speak("Done")
return
end
if m.moves[mvmn[lastm]]==nil then
m.moves[mvmn[lastm]]=true
speak("Checked.")
else
m.moves[mvmn[lastm]]=nil
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
r=runmenu(w,{"name: "..m.name,"health: "..m.health,"speed: "..m.speed,"attack: "..m.attack,"defence: "..m.defence,"team: "..m.team,"moves: "..mv,"controller: "..m.control,"remove fighter","finished"})
if r==1 then
speak("Please enter the name of this fighter, for example, the mighty warrior. Spaces are allowed.")
m.name=runedit(w)
if m.team=="unset" then m.team=m.name.."'s team" end
end
if r==2 then
speak("Please enter the health of this fighter, or the amount of hit points it should have. This value should be a number above 0, and we recommend between 10 and 300 points.")
m.health=tonumber(runedit(w))
end
if r==3 then
speak("Please enter the speed for this fighter. It should be above 0 and we recommend a value between 50 and 100. The speed value controls how likely it is that the fighter will take initiative")
m.speed=tonumber(runedit(w))
end
if r==4 then
speak("Please enter the attack value for this fighter. It should be a number that calculates the amount of damage added onto attacks. We recommend a value between -15 and 15, but your safest bet is 0.")
m.attack=tonumber(runedit(w))
end
if r==5 then
speak("Please enter the defence value for this fighter. It should be a number that calculates the amount of damage removed from incoming attacks. We recommend a value between -15 and 15, but your safest bet is 0.")
m.defence=tonumber(runedit(w))
end
if r==6 then
speak("Please enter the team of a fighter. For example: the warrior's alliance.")
m.team=runedit(w)
end
if r==9 then
if parent==nil then
speak("You can't delete this fighter, as it is not in any parent field (roster or playfield for instance)")
else
table.remove(parent,index)
speak("Done!")
return--no more fighter, ref is nil. Errors if we continue!
end
end
if r==7 then
movemenu(w,m)
end
if r==8 then
opt={"human","ai"}
speak("Select one of these two options")
m.control=opt[runmenu(w,opt)]
end
if r==10 then
if m.name=="unnamed" or len(m.moves)~=0 then speak("Sorry, but this fighter is not yet finished! If you made one by mistake or deleted all the moves, you need to add more.") else speak("Done!") return end
end
end
end

--in-game functions
--function to calculate damage and returns it, speaking damage output
function damage(dam)
dam=dam+launcher.attack
dam=dam-target.defence
if dam<0 then dam=0 end
speak(target.name.." took "..dam.." damage!")
return dam
end
--menu functions
function modmenu(w,m)
while true do
speak("Select a fighter to modify.")
mm={}
for i,j in pairs(m) do
table.insert(mm,j.name)
end
table.insert(mm,"new...")
table.insert(mm,"back")
r=runmenu(w,mm)
if r==#m+2 then
f=io.open("roster.json","w")
f:write(json.encode(roster))
f:close()
speak("Roster saved!")
return
end
if r==#m+1 then
nf=newfighter()
table.insert(m,deepcopy(nf))
modfighter(w,m[#m],roster,#m)
end
if r<#m+1 then
modfighter(w,m[r],roster,r)
end
end
end
function mainmenu()
music("menumus.ogg")
speak("Main menu. Please select an option.")
return runmenu(w,{"roster","playfield","play","extras","exit"})
end
--initializing main code goes here
w=newwindow("xtreme battle simulator 3 version "..version)
--logo=sound("xtreme games.ogg")
--logo.play()
--logotime=elapsed()
--repeat
--w.loop()
--until elapsed()-logotime>12.5
while true do
r=mainmenu()
if r==1 then modmenu(w,roster) end
if r==5 then speak("thanks for playing!") wait(1) mus.free() return 4 end
end
end
main()
