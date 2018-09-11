include( 'shared.lua' )

surface.CreateFont("Calibri21",{
    font = "calibri",
    size = 40,
    weight = 200,
    antialias = true,
})
surface.CreateFont("Calibri22",{
    font = "calibri",
    size = 64,
    weight = 200,
    antialias = true,
})

local text1 = "Not Ready"
local text2 = "Not Ready"
function RecieveReady()
    if net.ReadBool() then text1 = "Ready" else text1 = "Not Ready" end
    if net.ReadBool() then text2 = "Ready" else text2 = "Not Ready" end
end
net.Receive("SendReady", RecieveReady)

function GM:SpawnMenuOpen()
    return false
end


function GM:HUDPaint()

    surface.SetDrawColor(255, 0, 20, 255)
    surface.DrawRect(ScrW() / 2-253, 0, 164, 45)
    surface.SetDrawColor(20, 0, 255, 255)
    surface.DrawRect(ScrW() / 2+87, 0, 164, 45)
	surface.SetDrawColor(0, 0, 0, 255)
	draw.NoTexture()
    draw.Circle( ScrW() / 2, 0, 100, 30 )
	surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawLine(ScrW() / 2, 0, ScrW() / 2, 100)
    
    draw.DrawText(text1, "Calibri21", ScrW() / 2-245, 0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
    draw.DrawText(text2, "Calibri21", ScrW() / 2+245, 0, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
    draw.DrawText(team.GetScore(0), "Calibri22", ScrW() / 2-20, 0, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
    draw.DrawText(team.GetScore(1), "Calibri22", ScrW() / 2+20, 0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
end

function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end