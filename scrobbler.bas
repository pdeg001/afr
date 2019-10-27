﻿B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.8
@EndOfDesignText@
Sub Process_Globals
	Dim sf As StringFunctions
	
End Sub
#IgnoreWarnings: 9


Public Sub GetArtistAndSong(lst As List) As List
	Dim cleanList As List
	
	
	cleanList.Initialize
	
	For Each str As String In lst
		If str.Length > 2 Then
			cleanList.Add(str)
		End If
	Next
	
	
	Return cleanList
End Sub

Sub processLyrics(playing As String, reverse As Boolean) As String
	
	Dim artist, song, retArtist, retSong As String
	Dim playingList, cleanPlayingList As List
	Dim sb As StringBuilder
	
	playingList.Initialize
	cleanPlayingList.Initialize
	sf.Initialize
	
	playingList = Regex.Split(" - ", playing)
	
	cleanPlayingList = GetArtistAndSong(playingList)
	
	If cleanPlayingList.Size < 2 Then
		Return ""
	End If
	
	If cleanPlayingList.Size > 2 Then
		Return ""
	End If
	
	artist	= sf.Ltrim(cleanPlayingList.Get(0))
	artist	= sf.Rtrim(artist)
	
	song	= sf.Ltrim(cleanPlayingList.Get(1))
	song	= sf.Rtrim(song)
	artist	= sf.Lower(artist)
	song	= sf.Lower(song)

	
	If reverse = False Then
		retArtist	= herokuProcessAmp(artist).ToLowerCase
		retSong		= herokuProcessAmp(song).ToLowerCase
	Else 
		retArtist	= herokuProcessAmp(song).ToLowerCase
		retSong		= herokuProcessAmp(artist).ToLowerCase
	End If	
	
	
	retSong	= retSong.Replace("HI: ", "")
	CallSub2(Starter, "setSongTitle", retSong)
	Dim mArtist, mSong As String	
	
	mArtist = Starter.spotMap.Get("artistname")
	mSong	= Starter.spotMap.Get("artistsong")
	If mSong.ToLowerCase <> Starter.chartSong Then
		mSong = song
	End If
	
	sb.Initialize
	'http://www.songlyrics.com/gnarls-barkley/crazy-lyrics/
	sb.Append("https://lyric-api.herokuapp.com/api/find/")
'	sb.Append(retArtist.Replace(" ", " "))
	sb.Append(retArtist.Replace(" ", " "))
	sb.Append("/")
	'sb.Append(retSong.Replace(" ", " "))
	sb.Append(retSong.Replace(" ", " "))

	Return sb.ToString
End Sub

Sub herokuProcessAmp(value As String) As String
	Dim ampList As List
	Dim ampListSize As Int
	Dim newValue, tmpValue As String
	
	Starter.clsFunc.Initialize
	ampList.Initialize
	
	If value.IndexOf("&") > -1 Then
		ampList = Regex.Split("&", value)
		ampListSize = ampList.Size-1
		For i = 0 To ampListSize
			tmpValue = ampList.Get(i)
			If i = 0 Then
				newValue = tmpValue.Trim
			Else
				newValue = newValue & tmpValue.Trim
			End If
			If i < ampListSize Then
				newValue = newValue & " & "
			End If
						
		Next
	End If
	If newValue.Length > 0 Then
		value = newValue
	End If	
	Return value
End Sub


Sub processPlaying(playing As String) As String
	Dim artist, song, retArtist, retSong As String
	Dim playingList, cleanPlayingList As List
	Dim station As String = CallSub(player, "getStation")

	sf.Initialize

	playingList.Initialize
	cleanPlayingList.Initialize
	
	playingList = Regex.Split("-", playing)
	
	cleanPlayingList = GetArtistAndSong(playingList)

	
	If cleanPlayingList.Size < 2 Then
		Return ""
	End If
	
	If cleanPlayingList.Size > 2 Then
		Return ""
	End If
	
	For Each item As String In playingList
		
		If item.Length = 0 Then
			Return ""
		End If
	Next
	
	artist =  sf.Ltrim(cleanPlayingList.Get(0))
	artist =  sf.Rtrim(artist)
	song	= sf.Ltrim(cleanPlayingList.Get(1))
	song	= sf.Rtrim(song)
	artist = artist.Replace(" ft", "")
	retArtist 	= song
	retSong		= artist
	retArtist	= RemoveAccents(retArtist)
	retSong		= RemoveAccents(retSong)
	retSong		= retSong.Replace("HI:", "")
	
	
	Starter.chartArtist = removeSpecials(retArtist)
	Starter.chartSong	= removeSpecials(retSong)
		
	Dim spotSong As String
	
	spotSong = retArtist& " " & retSong
	spotSong = spotSong.Replace("+", "")
	spotSong = spotSong.Replace("*", "")

	Return spotSong
End Sub

Private Sub removeSpecials(str As String) As String
	str	= str.Replace("*", "")
	str	= str.Replace("+", "")
	
	Return str
End Sub

Sub RemoveAccents(s As String) As String
	Dim normalizer As JavaObject
	normalizer.InitializeStatic("java.text.Normalizer")
	Dim n As String = normalizer.RunMethod("normalize", Array As Object(s, "NFD"))
	Dim sb As StringBuilder
	sb.Initialize
	For i = 0 To n.Length - 1
		If Regex.IsMatch("\p{InCombiningDiacriticalMarks}", n.CharAt(i)) = False  Then
			sb.Append(n.CharAt(i))
		End If
	Next
	Return sb.ToString
End Sub


'Sub createLyricsOnDemand(reverse As Boolean) As String
'	Dim artist, song As String
'	
'	artist	= Starter.chartArtist.ToLowerCase
'	song	= Starter.chartSong.ToLowerCase
'	artist = Starter.spotMap.Get("artistname")
'	song = Starter.spotMap.Get("artistsong")
'	
''	artist = artist.ToLowerCase
''	song = song.ToLowerCase
'	If artist = Null Or artist = "" Then Return "noUrl"
'	
'	artist	= Starter.clsFunc.replacetekens(artist)
'	song	= Starter.clsFunc.replacetekens(song)
'	
'	song	= song.Replace(" ", "")
'	artist	= artist.Replace("'", "")
'	song	= song.Replace("'", "")
'	artist	= artist.Replace("&", "")
'	song	= song.Replace("&", "")
'	artist	= artist.Replace("(", "")
'	song	= song.Replace(")", "")
'	artist	= artist.Replace(".", "")
'	artist	= artist.Replace("-", "")
''	artist	= artist.Replace("the", "")
'	song	= song.Replace(".", "")
'	song	= song.Replace("?", "")
'	song	= song.Replace("!", "")
'	If reverse = False Then
'		Return $"https://www.lyricsondemand.com/${artist.SubString2(0,1)}/${artist}/${song}lyrics.html"$
'	Else	
'		Return $"https://www.lyricsondemand.com/${song.SubString2(0,1)}/${song}/${artist}lyrics.html"$
'	End If
'	
''	Return $"https://www.lyricsondemand.com/${artist.SubString2(0,1).ToLowerCase}/${artist}lyrics/${song}lyrics.html"$
'End Sub