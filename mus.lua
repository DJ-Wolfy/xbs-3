cmus=""
function check_for_music_volumes(w)
if mus~=nil then
if w.pressed("lalt")==1 then
speak(tostring(mus.volume))
end
if mus.volume<=0.99 and w.pressed("pageup")==1 then
mus.volume=mus.volume +0.1
end
if mus.volume>=0.01 and w.pressed("pagedown")==1 then
mus.volume=mus.volume-0.1
end
end
end
function music(mname)
if cmus==mname then
return
end
if mus~=nil then
v=mus.volume
for i=mus.volume,0,-0.01 do
mus.volume=i
wait(0.1)
end
mus.stop()
end
mus=sound(mname)
if v~=nil then mus.volume=v else mus.volume=0.5 end
mus.looping=1
mus.play()
cmus=mname
end
