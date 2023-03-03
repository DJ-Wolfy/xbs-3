moves["punch"]={
name="punch",
offensive=true,
sound="xsound/jab.ogg",
play=function(l,t)
stat(l,"attack",1)
damage(math.random(1,10))

end
}
moves["kick"]={
name="kick",
offensive=true,
play=function(l,t)
speak("Ow, that hurt a lot!")
end
}
