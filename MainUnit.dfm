object Analizator: TAnalizator
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = #1040#1085#1072#1083#1080#1079#1072#1090#1086#1088
  ClientHeight = 800
  ClientWidth = 1200
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Load_: TButton
    Left = 522
    Top = 662
    Width = 660
    Height = 49
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1082#1086#1076' '#1080#1079' '#1092#1072#1081#1083#1072
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -37
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
    TabOrder = 2
    OnClick = Load_Click
  end
  object StartWork_: TButton
    Left = 522
    Top = 734
    Width = 324
    Height = 49
    Caption = #1040#1085#1072#1083#1080#1079
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -37
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
    TabOrder = 3
    OnClick = StartWork_Click
  end
  object Exit_: TButton
    Left = 858
    Top = 734
    Width = 324
    Height = 49
    Caption = #1042#1099#1093#1086#1076
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -37
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
    TabOrder = 4
    OnClick = Exit_Click
  end
  object Table_: TStringGrid
    Left = 519
    Top = 8
    Width = 663
    Height = 622
    ColCount = 6
    DefaultColWidth = 106
    FixedCols = 0
    RowCount = 101
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Lucida Console'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColMoving, goRowSelect]
    ParentFont = False
    TabOrder = 1
  end
  object ProgramText_: TRichEdit
    Left = 8
    Top = 8
    Width = 497
    Height = 622
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
    WantTabs = True
    Zoom = 100
  end
  object ResultText_: TRichEdit
    Left = 8
    Top = 662
    Width = 497
    Height = 121
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Lucida Console'
    Font.Style = []
    Lines.Strings = (
      ''
      ''
      ''
      ''
      '')
    ParentFont = False
    ReadOnly = True
    TabOrder = 5
    Zoom = 100
  end
  object DlgOpen_: TOpenDialog
    Title = #1042#1099#1073#1077#1088#1080#1090#1077' '#1092#1072#1081#1083
    Left = 24
    Top = 736
  end
end
