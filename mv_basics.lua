moves["light jab"]={
name="light jab",
sound="xsound/jab.ogg",
offensive=true,
play=function(l,t)
damage(math.random(4,8))
end
}
moves["jab"]={
name="jab",
sound="xsound/jab.ogg",
offensive=true,
play=function(l,t)
damage(math.random(4,8))
if l.last_jab==turn-1 then
speak("Combo attack!")
damage(math.random(3,6))
end
l.last_jab=turn
stat(l,"speed",-4)
end
}
moves["kick"]={
name="kick",
sound="psound/jab.wav",
offensive=true,
play=function(l,t)
if math.random(1,4)==1 then
speak(l.name.." missed and fell, taking 3 damage!")
l.health=l.health-3
else
damage(6,11)
end
end
}
moves["tackle"]={
name="tackle",
sound="xsound/lock.ogg",
offensive=true,
play=function(l,t)
stat(l,"speed",-15)
stat(t,"attack",-2)
stat(t,"speed",-8)
end
}
moves["rush in"]={
name="rush in",
play=function(l)
stat(l,"attack",3)
stat(l,"speed",8)
stat(l,"defence",-5)
end
}
moves["run away"]={
name="run away",
play=function(l)
stat(l,"speed",25)
stat(l,"attack",-6)
stat(l,"defence",-7)
if l.speed>200 then
speak(l.name.." is going too fast!")
l.speed=200
end
end
}
moves["hook"]={
name="hook",
sound="xsound/jab.ogg",
offensive=true,
play=function(l,t)
damage(math.random(5,9))
stat(l,"attack",-2)
if math.random(1,3)==1 then
speak(t.name.." has gotten a concussion!")
stat(t,"defence",-4)
end
end
}
moves["pummel"]={
name="pummel",
sound="xsound/bodyslam.ogg",
offensive=true,
play=function(l,t)
damage(math.random(3,5))
wait(900)
punches=math.random(2,8)
if l.attack>0 then
punches=punches+l.attack*2
end
for i=1,punches do
play("xsound/jab.ogg",50,50-math.random(0,100))
wait(math.random(110,130))
end
t.health=t.health-punches
speak(t.name.." took "..punches.." damage!")
stat(l,"speed",-20)
end
}
moves["circle"]={
name="circle",
offensive=true,
play=function(l,t)
stat(l,"attack",3)
stat(t,"attack",3)
end
}
moves["spinning punch"]={
name="spinning punch",
sound="psound/jab.wav",
offensive=true,
play=function(l,t)
damage(math.random(9,13))
stat(t,"attack",-4)
stat(l,"attack",-2)
stat(l,"defence",-2)
stat(t,"speed",-6)
end
}
moves["mega laser"]={
name="mega laser",
offensive=true,
play=function(l,t)
if l.megalasercharge~=1 then
l.megalasercharge=1
speak(l.name.." is charging up...")
stat(l,"speed",-16)
else
play("xsound/megalaser.ogg",50,0)
damage(math.random(15,20))
stat(l,"speed",12)
l.megalasercharge=0
end
end
}
moves["drain"]={
name="drain",
offensive=true,
play=function(l,t)
d=damage(8,12)
dr=math.floor(d/3)
l.health=l.health+dr
speak(l.name.." gained "..dr.." health!")
end
}
moves["magic strength"]={
name="magic strength",
sound="osound/magic.wav",
play=function(l)
stat(l,"attack",4)
end
}
moves["magic shield"]={
name="magic shield",
sound="osound/magic.wav",
play=function(l)
stat(l,"defence",2)
end
}
moves["haste"]={
name="haste",
sound="osound/magic.wav",
play=function(l)
stat(l,"speed",12)
end
}
moves["combo punch"]={
name="combo punch",
offensive=true,
play=function(l,t)
play("psound/jab.wav",50,50)
damage(math.random(5,7))
wait(250)
play("psound/jab.wav",50,-50)
damage(math.random(5,7))
end
}
moves["relive pain"]={
name="relive pain",
sound="osound/undead.wav",
offensive=true,
play=function(l,t)
if l.lastdamage~=nil then
nd=math.floor(l.lastdamage/2)
speak(l.name.." relives their pain! "..l.name.." took "..nd.." damage!")
l.health=l.health-nd
damage(nd)
end
end
}
moves["heal"]={
name="heal",
sound="osound/magic.wav",
play=function(l)
regain=math.random(3,7)
speak(l.name.." regained "..regain.." health!")
l.health=l.health+regain
end
}
moves["poison bomb"]={
name="poison bomb",
sound="xsound/poisonbomb.ogg",
offensive=true,
play=function(l,t)
if t.poisoned==nil then
t.poisoned=0
end
if t.poisoned<0 then
t.poisoned=0
end
damage(math.random(3,6))
stat(t,"poison",4)
stat(t,"defence",-2)
stat(l,"attack",-3)
end
}
turn_start_triggers["poisoned"]=function(l)
if l.poison==nil then l.poison=-1 end
if l.poison==0 then
speak(l.name.."'s poison has worn off.")
elseif l.poison>0 then
speak(l.name.." is poisoned!")
l.health=l.health-3
speak(l.name.." took 3 damage!")
l.poison=l.poison-1
wait(1200)
end
end
moves["parry"]={
name="parry",
secret=true,
play=function(l)
if l.parrying==0 or l.parrying==nil then
l.parrying=1
l.speed=l.speed-20
end
end

}
turn_start_triggers["parry"]=function(l)
if l.parrying == 1 then
speak(l.name.." didn't parry any attacks and is off balance!")
wait(600)
stat(l,"speed",20)
stat(l,"defence",-2)
stat(l,"parrying",-1)
end
end
prefire_triggers["parry"]=function(m,l,t)
if t~=nil then
if t.parrying == 1 then
wait(120)
speak(t.name.." parried the attack!")
play("psound/warhammer.wav")
stat(t,"parrying",-1)
stat(t,"defence",2)
stat(t,"speed",12)
return true
end
end
return nil
end
moves["trick"]={
name="trick",
secret=true,
play=function(l)
end
}
moves["mega machinegun"]={
name="mega machinegun",
offensive=true,
play=function(l,t)
if l.megamachineguncharge==nil then l.megamachineguncharge=0 end
if l.megamachineguncharge==0 then
l.megamachineguncharge=1
speak("charging up...")
elseif l.megamachineguncharge==1 then
l.megamachineguncharge=2
speak("Activating...")
elseif l.megamachineguncharge==2 then
speak("Mega machinegun almost charged up!")
l.megamachineguncharge=3
else
wait(1500)
speak("Fire!")
wait(500)
for i=1,6 do
play("psound/handgrenade.wav")
damage(3)
wait(500)
end
end
end
}
