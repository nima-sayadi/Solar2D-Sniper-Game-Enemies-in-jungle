local Util = {};
function Util:playShoot(file,vol,channel)
    local music = audio.loadStream("sound/"..file);
    audio.play(music,{loops = 0,channel});
    audio.setVolume(vol,{channel});
end
return Util;