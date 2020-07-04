exports.pw_chat:AddChatCommand('e', function(source, args, rawCommand)
    local _src = source
    local argh = args[1] or "cancel"
    TriggerClientEvent('pw_animations:doAnimation', _src, argh)
end, {
    help = "Do an Animation",
    params = {
        {
            name = "Animation Name",
            help = "salute, finger, finger2, phonecall, surrender, facepalm, notes, brief, brief2, foldarms, foldarms2, damn, fail, gang1, gang2, no, pickbutt, grabcrotch, peace, cigar, cigar2, joint, cig, holdcigar, holdcig, holdjoint, dead, holster, aim, aim2, slowclap, box, cheer, bum, leanwall, copcrowd, copcrowd2, copidle, shotbar, drunkbaridle, djidle, djidle2, fdance1, fdance2, mdance1, mdance2, walk1-44"
        },
    }
}, -1)