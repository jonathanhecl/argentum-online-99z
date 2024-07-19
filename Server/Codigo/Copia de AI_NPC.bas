Attribute VB_Name = "AI"
'Argentum Online 0.9.0.122
'Copyright (C) 2001 M�rquez Pablo Ignacio
'
'This program is free software; you can redistribute it and/or modify
'it under the terms of the GNU General Public License as published by
'the Free Software Foundation; either version 2 of the License, or
'any later version.
'
'This program is distributed in the hope that it will be useful,
'but WITHOUT ANY WARRANTY; without even the implied warranty of
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'GNU General Public License for more details.
'
'You should have received a copy of the GNU General Public License
'along with this program; if not, write to the Free Software
'Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
'
'Argentum Online is based in Baronsoft's VB6 Online RPG
'Engine 9/08/2000 http://www.baronsoft.com/
'aaron@baronsoft.com
'
'Contact info:
'Pablo Ignacio M�rquez
'morgolock@speedy.com.ar
'www.geocities.com/gmorgolock
'Calle 3 n�mero 983 piso 7 dto A
'La Plata - Pcia, Buenos Aires - Republica Argentina
'C�digo Postal 1900


Option Explicit

Public Const ESTATICO = 1
Public Const MUEVE_AL_AZAR = 2
Public Const NPC_MALO_ATACA_USUARIOS_BUENOS = 3
Public Const NPCDEFENSA = 4
Public Const GUARDIAS_ATACAN_CRIMINALES = 5
Public Const SIGUE_AMO = 8
Public Const NPC_ATACA_NPC = 9



'?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
'?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
'?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
'                        Modulo AI_NPC
'?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
'?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
'?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
'AI de los NPC
'?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
'?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
'?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

Private Sub GuardiasAI(ByVal NpcIndex As Integer)
Dim nPos As WorldPos
Dim HeadingLoop As Byte
Dim tHeading As Byte
Dim Y As Integer
Dim X As Integer
Dim UI As Integer
For HeadingLoop = NORTH To WEST
    nPos = Npclist(NpcIndex).Pos
    Call HeadtoPos(HeadingLoop, nPos)
    If InMapBounds(nPos.Map, nPos.X, nPos.Y) Then
        UI = MapData(nPos.Map, nPos.X, nPos.Y).UserIndex
        If UI > 0 Then
              If UserList(UI).Flags.Muerto = 0 Then
                     '�ES CRIMINAL?
                     If Criminal(UI) Then
                            Call ChangeNPCChar(ToMap, 0, nPos.Map, NpcIndex, Npclist(NpcIndex).Char.Body, Npclist(NpcIndex).Char.Head, HeadingLoop)
                            Call NpcAtacaUser(NpcIndex, UI)
                            Exit Sub
                     ElseIf Npclist(NpcIndex).Flags.AttackedBy = UserList(UI).Name _
                               And Not Npclist(NpcIndex).Flags.Follow Then
                           Call ChangeNPCChar(ToMap, 0, nPos.Map, NpcIndex, Npclist(NpcIndex).Char.Body, Npclist(NpcIndex).Char.Head, HeadingLoop)
                           Call NpcAtacaUser(NpcIndex, UI)
                           Exit Sub
                     End If
              End If
        End If
    End If
Next HeadingLoop
End Sub

Private Sub HostilMalvadoAI(ByVal NpcIndex As Integer)
Dim nPos As WorldPos
Dim HeadingLoop As Byte
Dim tHeading As Byte
Dim Y As Integer
Dim X As Integer
Dim UI As Integer

For HeadingLoop = NORTH To WEST
    nPos = Npclist(NpcIndex).Pos
    Call HeadtoPos(HeadingLoop, nPos)
    If InMapBounds(nPos.Map, nPos.X, nPos.Y) Then
        UI = MapData(nPos.Map, nPos.X, nPos.Y).UserIndex
        If UI > 0 Then
            If UserList(UI).Flags.Muerto = 0 Then
                If Npclist(NpcIndex).Flags.LanzaSpells <> 0 Then
                    Dim k As Integer
                    k = RandomNumber(1, Npclist(NpcIndex).Flags.LanzaSpells)
                    Call NpcLanzaUnSpell(NpcIndex, UI)
                End If
                Call ChangeNPCChar(ToMap, 0, nPos.Map, NpcIndex, Npclist(NpcIndex).Char.Body, Npclist(NpcIndex).Char.Head, HeadingLoop)
                Call NpcAtacaUser(NpcIndex, MapData(nPos.Map, nPos.X, nPos.Y).UserIndex)
                Exit Sub
            End If
        End If
    End If
Next HeadingLoop

End Sub


Private Sub HostilBuenoAI(ByVal NpcIndex As Integer)

Dim nPos As WorldPos
Dim HeadingLoop As Byte
Dim tHeading As Byte
Dim Y As Integer
Dim X As Integer
Dim UI As Integer

For HeadingLoop = NORTH To WEST
    nPos = Npclist(NpcIndex).Pos
    Call HeadtoPos(HeadingLoop, nPos)
    If InMapBounds(nPos.Map, nPos.X, nPos.Y) Then
        UI = MapData(nPos.Map, nPos.X, nPos.Y).UserIndex
        If UI > 0 Then
            If UserList(UI).Name = Npclist(NpcIndex).Flags.AttackedBy Then
                If UserList(UI).Flags.Muerto = 0 Then
                        If Npclist(NpcIndex).Flags.LanzaSpells > 0 Then
                          Dim k As Integer
                          k = RandomNumber(1, Npclist(NpcIndex).Flags.LanzaSpells)
                          Call NpcLanzaUnSpell(NpcIndex, UI)
                        End If
                        Call ChangeNPCChar(ToMap, 0, nPos.Map, NpcIndex, Npclist(NpcIndex).Char.Body, Npclist(NpcIndex).Char.Head, HeadingLoop)
                        Call NpcAtacaUser(NpcIndex, UI)
                        Exit Sub
                End If
            End If
        End If
    End If
Next HeadingLoop

End Sub

Private Sub IrUsuarioCercano(ByVal NpcIndex As Integer)
Dim nPos As WorldPos
Dim HeadingLoop As Byte
Dim tHeading As Byte
Dim Y As Integer
Dim X As Integer
Dim UI As Integer
For Y = Npclist(NpcIndex).Pos.Y - 10 To Npclist(NpcIndex).Pos.Y + 10
    For X = Npclist(NpcIndex).Pos.X - 10 To Npclist(NpcIndex).Pos.X + 10
        If X >= MinXBorder And X <= MaxXBorder And Y >= MinYBorder And Y <= MaxYBorder Then
               UI = MapData(Npclist(NpcIndex).Pos.Map, X, Y).UserIndex
               If UI > 0 Then
                  If UserList(UI).Flags.Muerto = 0 And UserList(UI).Flags.Invisible = 0 Then
                       If Npclist(NpcIndex).Flags.LanzaSpells <> 0 Then Call NpcLanzaUnSpell(NpcIndex, UI)
                       tHeading = FindDirection(Npclist(NpcIndex).Pos, UserList(MapData(Npclist(NpcIndex).Pos.Map, X, Y).UserIndex).Pos)
                       Call MoveNPCChar(NpcIndex, tHeading)
                       Exit Sub
                  End If
               End If
        End If
    Next X
Next Y
End Sub

Private Sub SeguirAgresor(ByVal NpcIndex As Integer)
Dim nPos As WorldPos
Dim HeadingLoop As Byte
Dim tHeading As Byte
Dim Y As Integer
Dim X As Integer
Dim UI As Integer
For Y = Npclist(NpcIndex).Pos.Y - 10 To Npclist(NpcIndex).Pos.Y + 10
    For X = Npclist(NpcIndex).Pos.X - 10 To Npclist(NpcIndex).Pos.X + 10
        If X >= MinXBorder And X <= MaxXBorder And Y >= MinYBorder And Y <= MaxYBorder Then
            UI = MapData(Npclist(NpcIndex).Pos.Map, X, Y).UserIndex
            If UI > 0 Then
                If UserList(UI).Name = Npclist(NpcIndex).Flags.AttackedBy Then
                    If UserList(UI).Flags.Muerto = 0 And UserList(UI).Flags.Invisible = 0 Then
                         If Npclist(NpcIndex).Flags.LanzaSpells > 0 Then
                              Dim k As Integer
                              k = RandomNumber(1, Npclist(NpcIndex).Flags.LanzaSpells)
                              Call NpcLanzaUnSpell(NpcIndex, UI)
                         End If
                         tHeading = FindDirection(Npclist(NpcIndex).Pos, UserList(MapData(Npclist(NpcIndex).Pos.Map, X, Y).UserIndex).Pos)
                         Call MoveNPCChar(NpcIndex, tHeading)
                         Exit Sub
                    End If
                End If
            End If
        End If
    Next X
Next Y
End Sub

Private Sub PersigueCriminal(ByVal NpcIndex As Integer)
Dim UI As Integer
Dim nPos As WorldPos
Dim HeadingLoop As Byte
Dim tHeading As Byte
Dim Y As Integer
Dim X As Integer
For Y = Npclist(NpcIndex).Pos.Y - 10 To Npclist(NpcIndex).Pos.Y + 10
    For X = Npclist(NpcIndex).Pos.X - 10 To Npclist(NpcIndex).Pos.X + 10
        If X >= MinXBorder And X <= MaxXBorder And Y >= MinYBorder And Y <= MaxYBorder Then
           UI = MapData(Npclist(NpcIndex).Pos.Map, X, Y).UserIndex
           If UI > 0 Then
                If Criminal(UI) Then
                   If UserList(UI).Flags.Muerto = 0 And UserList(UI).Flags.Invisible = 0 Then
                        If Npclist(NpcIndex).Flags.LanzaSpells > 0 Then
                              Dim k As Integer
                              k = RandomNumber(1, Npclist(NpcIndex).Flags.LanzaSpells)
                              Call NpcLanzaUnSpell(NpcIndex, UI)
                        End If
                        tHeading = FindDirection(Npclist(NpcIndex).Pos, UserList(MapData(Npclist(NpcIndex).Pos.Map, X, Y).UserIndex).Pos)
                        Call MoveNPCChar(NpcIndex, tHeading)
                        Exit Sub
                   End If
                End If
           End If
        End If
    Next X
Next Y
End Sub

Private Sub SeguirAmo(ByVal NpcIndex As Integer)
Dim nPos As WorldPos
Dim HeadingLoop As Byte
Dim tHeading As Byte
Dim Y As Integer
Dim X As Integer
Dim UI As Integer
For Y = Npclist(NpcIndex).Pos.Y - 10 To Npclist(NpcIndex).Pos.Y + 10
    For X = Npclist(NpcIndex).Pos.X - 10 To Npclist(NpcIndex).Pos.X + 10
        If X >= MinXBorder And X <= MaxXBorder And Y >= MinYBorder And Y <= MaxYBorder Then
            If Npclist(NpcIndex).Target = 0 And Npclist(NpcIndex).TargetNpc = 0 Then
                UI = MapData(Npclist(NpcIndex).Pos.Map, X, Y).UserIndex
                If UI > 0 Then
                   If UserList(UI).Flags.Muerto = 0 _
                   And UserList(UI).Flags.Invisible = 0 _
                   And UI = Npclist(NpcIndex).MaestroUser _
                   And Distancia(Npclist(NpcIndex).Pos, UserList(UI).Pos) > 3 Then
                        tHeading = FindDirection(Npclist(NpcIndex).Pos, UserList(MapData(Npclist(NpcIndex).Pos.Map, X, Y).UserIndex).Pos)
                        Call MoveNPCChar(NpcIndex, tHeading)
                        Exit Sub
                   End If
                End If
            End If
        End If
    Next X
Next Y
End Sub

Private Sub AiNpcAtacaNpc(ByVal NpcIndex As Integer)
Dim nPos As WorldPos
Dim HeadingLoop As Byte
Dim tHeading As Byte
Dim Y As Integer
Dim X As Integer
Dim NI As Integer
Dim bNoEsta As Boolean
For Y = Npclist(NpcIndex).Pos.Y - 10 To Npclist(NpcIndex).Pos.Y + 10
    For X = Npclist(NpcIndex).Pos.X - 10 To Npclist(NpcIndex).Pos.X + 10
        If X >= MinXBorder And X <= MaxXBorder And Y >= MinYBorder And Y <= MaxYBorder Then
           NI = MapData(Npclist(NpcIndex).Pos.Map, X, Y).NpcIndex
           If NI > 0 Then
                If Npclist(NpcIndex).TargetNpc = NI Then
                     bNoEsta = True
                     tHeading = FindDirection(Npclist(NpcIndex).Pos, Npclist(MapData(Npclist(NpcIndex).Pos.Map, X, Y).NpcIndex).Pos)
                     Call MoveNPCChar(NpcIndex, tHeading)
                     Call NpcAtacaNpc(NpcIndex, NI)
                     Exit Sub
                End If
           End If
           
        End If
    Next X
Next Y

If Not bNoEsta Then
    If Npclist(NpcIndex).MaestroUser > 0 Then
        Call FollowAmo(NpcIndex)
    Else
        Npclist(NpcIndex).Movement = Npclist(NpcIndex).Flags.OldMovement
        Npclist(NpcIndex).Hostile = Npclist(NpcIndex).Flags.OldHostil
    End If
End If
    
End Sub

Function NPCAI(ByVal NpcIndex As Integer)
On Error GoTo ErrorHandler
        '<<<<<<<<<<< Ataques >>>>>>>>>>>>>>>>
        If Npclist(NpcIndex).MaestroUser = 0 Then
            'Busca a alguien para atacar
            '�Es un guardia?
            If Npclist(NpcIndex).NPCtype = NPCTYPE_GUARDIAS Then
                    Call GuardiasAI(NpcIndex)
            ElseIf Npclist(NpcIndex).Hostile And Npclist(NpcIndex).Stats.Alineacion <> 0 Then
                    Call HostilMalvadoAI(NpcIndex)
            ElseIf Npclist(NpcIndex).Hostile And Npclist(NpcIndex).Stats.Alineacion = 0 Then
                    Call HostilBuenoAI(NpcIndex)
            End If
        Else
            'Evitamos que ataque a su amo, a menos
            'que el amo lo ataque.
            Call HostilBuenoAI(NpcIndex)
        End If
        
        '<<<<<<<<<<<Movimiento>>>>>>>>>>>>>>>>
        Select Case Npclist(NpcIndex).Movement
            Case MUEVE_AL_AZAR
                If Npclist(NpcIndex).NPCtype = NPCTYPE_GUARDIAS Then
                    If Int(RandomNumber(1, 12)) = 3 Then
                        Call MoveNPCChar(NpcIndex, CByte(RandomNumber(1, 4)))
                    End If
                    Call PersigueCriminal(NpcIndex)
                Else
                    If Int(RandomNumber(1, 12)) = 3 Then
                        Call MoveNPCChar(NpcIndex, CByte(RandomNumber(1, 4)))
                    End If
                End If
            'Va hacia el usuario cercano
            Case NPC_MALO_ATACA_USUARIOS_BUENOS
                Call IrUsuarioCercano(NpcIndex)
            'Va hacia el usuario que lo ataco(FOLLOW)
            Case NPCDEFENSA
                Call SeguirAgresor(NpcIndex)
            'Persigue criminales
            Case GUARDIAS_ATACAN_CRIMINALES
                Call PersigueCriminal(NpcIndex)
            Case SIGUE_AMO
                Call SeguirAmo(NpcIndex)
                If Int(RandomNumber(1, 12)) = 3 Then
                        Call MoveNPCChar(NpcIndex, CByte(RandomNumber(1, 4)))
                End If
            Case NPC_ATACA_NPC
                Call AiNpcAtacaNpc(NpcIndex)
        End Select


Exit Function


ErrorHandler:
    Call LogError("NPCAI " & Npclist(NpcIndex).Name & " " & Npclist(NpcIndex).MaestroUser & " " & Npclist(NpcIndex).MaestroNpc & " mapa:" & Npclist(NpcIndex).Pos.Map & " x:" & Npclist(NpcIndex).Pos.X & " y:" & Npclist(NpcIndex).Pos.Y & " Mov:" & Npclist(NpcIndex).Movement & " TargU:" & Npclist(NpcIndex).Target & " TargN:" & Npclist(NpcIndex).TargetNpc)
    Dim MiNPC As Npc
    MiNPC = Npclist(NpcIndex)
    Call QuitarNPC(NpcIndex)
    Call ReSpawnNpc(MiNPC)
    
End Function

Sub NpcLanzaUnSpell(ByVal NpcIndex As Integer, ByVal UserIndex As Integer)

If UserList(UserIndex).Flags.Invisible = 1 Then Exit Sub

Dim k As Integer
k = RandomNumber(1, Npclist(NpcIndex).Flags.LanzaSpells)
Call NpcLanzaSpellSobreUser(NpcIndex, UserIndex, Npclist(NpcIndex).Spells(k))

End Sub

