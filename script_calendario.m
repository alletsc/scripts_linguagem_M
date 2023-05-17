//Este script gera automaticamente uma tabela dCalendario com o intervalo de datas dos Anos informados incluindo os Feriados Nacionais conforme site da ANBIMA
//AnoInicial: Informar o menor ano da dCalendario (deve ser maior ou igual a 2001).
//AnoFinal: Informar o maior ano da dCalendario (deve ser menor ou igual a 2078).
//N_Dia_Util_Do_Mes: Informar o enésimo dia útil do mês que queira que seja identificado. Ex.: 1 para primeiro dia útil, 5 para quinto dia útil, 10 para décimo dia útil etc
(AnoInicial as number, AnoFinal as number, N_Dia_Util_Do_Mes as number) =>
    let
        Consulta2 =
            let
                Fonte = List.Dates(
                    #date(AnoInicial, 1, 1),
                    Duration.Days(#date(AnoFinal, 12, 31) - #date(AnoInicial, 1, 1)) + 1,
                    #duration(1, 0, 0, 0)
                ),
                #"Convertido para Tabela" = Table.FromList(
                    Fonte, Splitter.SplitByNothing(), null, null, ExtraValues.Error
                ),
                #"Colunas Renomeadas" = Table.RenameColumns(#"Convertido para Tabela", {{"Column1", "Data"}}),
                #"Tipo Alterado" = Table.TransformColumnTypes(#"Colunas Renomeadas", {{"Data", type date}}),
                #"Dia Inserido" = Table.AddColumn(#"Tipo Alterado", "Dia", each Date.Day([Data]), Int64.Type),
                DiadaSemanaNum = Table.AddColumn(
                    #"Dia Inserido", "DiaSemana", each Date.DayOfWeek([Data]), Int64.Type
                ),
                DiadaSemana = Table.AddColumn(
                    DiadaSemanaNum, "NomeDiaSemana", each Date.DayOfWeekName([Data]), type text
                ),
                DiadaSemanaReduzido = Table.TransformColumns(
                    DiadaSemana, {{"NomeDiaSemana", each Text.Start(_, 3), type text}}
                ),
                DiaUtil = Table.AddColumn(
                    DiadaSemanaReduzido, "DiaUtil", each if [DiaSemana] = 0 or [DiaSemana] = 6 then 0 else 1,
                    Int64.Type
                ),
                #"Mês Inserido" = Table.AddColumn(DiaUtil, "MesNum", each Date.Month([Data]), Int64.Type),
                #"Nome do Mês Inserido" = Table.AddColumn(
                    #"Mês Inserido", "Mes", each Date.MonthName([Data]), type text
                ),
                #"Primeiros caracteres extraídos" = Table.TransformColumns(
                    #"Nome do Mês Inserido", {{"Mes", each Text.Start(_, 3), type text}}
                ),
                #"Ano Inserido" = Table.AddColumn(
                    #"Primeiros caracteres extraídos", "Ano", each Date.Year([Data]), Int64.Type
                ),
                #"Personalização Adicionada" = Table.AddColumn(
                    #"Ano Inserido", "AnoMesNum", each [Ano] * 100 + [MesNum], Int64.Type
                ),
                #"Personalização Adicionada1" = Table.AddColumn(
                    #"Personalização Adicionada", "AnoMes", each Number.ToText([Ano]) & "-" & [Mes], type text
                ),
                #"Personalização Adicionada2" = Table.AddColumn(
                    #"Personalização Adicionada1",
                    "AnoSemestreNum",
                    each if [MesNum] < 7 then [Ano] * 10 + 1 else [Ano] * 10 + 2,
                    Int64.Type
                ),
                #"Personalização Adicionada3" = Table.AddColumn(
                    #"Personalização Adicionada2",
                    "AnoSemestre",
                    each if [MesNum] < 7 then Text.From([Ano]) & "-S1" else Text.From([Ano]) & "-S2",
                    type text
                ),
                #"Personalização Adicionada4" = Table.AddColumn(
                    #"Personalização Adicionada3",
                    "AnoQuadrimestreNum",
                    each if [MesNum] < 5 then [Ano] * 10 + 1 else if [MesNum] < 9 then [Ano] * 10 + 2 else [Ano] * 10 + 3,
                    Int64.Type
                ),
                #"Coluna Condicional Adicionada" = Table.AddColumn(
                    #"Personalização Adicionada4",
                    "AnoQuadrimestre",
                    each
                        if [MesNum] < 5 then
                            Text.From([Ano]) & "-Q1"
                        else if [MesNum] < 9 then
                            Text.From([Ano]) & "-Q2"
                        else
                            Text.From([Ano]) & "-Q3",
                    type text
                ),
                #"Trimestre Inserido" = Table.AddColumn(
                    #"Coluna Condicional Adicionada",
                    "AnoTrimestreNum",
                    each [Ano] * 10 + Date.QuarterOfYear([Data]),
                    Int64.Type
                ),
                #"Personalização Adicionada5" = Table.AddColumn(
                    #"Trimestre Inserido",
                    "AnoTrimestre",
                    each Text.From([Ano]) & "-T" & Text.From(Date.QuarterOfYear([Data])),
                    type text
                ),
                #"Personalização Adicionada7" = Table.AddColumn(
                    #"Personalização Adicionada5",
                    "AnoBimestreNum",
                    each
                        [Ano] * 100 + (
                            if [MesNum] < 3 then
                                1
                            else if [MesNum] < 5 then
                                2
                            else if [MesNum] < 7 then
                                3
                            else if [MesNum] < 9 then
                                4
                            else if [MesNum] < 11 then
                                5
                            else
                                6
                        ),
                    Int64.Type
                ),
                #"Personalização Adicionada8" = Table.AddColumn(
                    #"Personalização Adicionada7",
                    "AnoBimestre",
                    each
                        Text.From([Ano])
                            & "-"
                            & (
                                if [MesNum] < 3 then
                                    "B1"
                                else if [MesNum] < 5 then
                                    "B2"
                                else if [MesNum] < 7 then
                                    "B3"
                                else if [MesNum] < 9 then
                                    "B4"
                                else if [MesNum] < 11 then
                                    "B5"
                                else
                                    "B6"
                            ),
                    type text
                ),
                #"Semana do Ano Inserida" = Table.AddColumn(
                    #"Personalização Adicionada8", "SemanaDoAno", each Date.WeekOfYear([Data]), Int64.Type
                ),
                SemanaDoMes = Table.AddColumn(
                    #"Semana do Ano Inserida", "SemanaDoMes", each Date.WeekOfMonth([Data]), Int64.Type
                ),
                #"Personalização Adicionada6" = Table.AddColumn(
                    SemanaDoMes, "OrdemMes", each ([Ano] - AnoInicial) * 12 + [MesNum], Int64.Type
                )
            in
                #"Personalização Adicionada6",
        #"Outras Colunas Removidas" = Table.SelectColumns(Consulta2, {"Ano"}),
        #"Duplicatas Removidas" = Table.Distinct(#"Outras Colunas Removidas"),
        #"Tipo Alterado" = Table.TransformColumnTypes(#"Duplicatas Removidas", {{"Ano", type text}}),
        FeriadosNacionais = (Ano as text) =>
            let
                Fonte = Web.BrowserContents("https://www.anbima.com.br/feriados/fer_nacionais/" & Ano & ".asp"),
                #"Tabela extraída de HTML" = Html.Table(
                    Fonte,
                    {
                        {"Column1", "TABLE.interna > * > TR > :nth-child(1)"},
                        {"Column2", "TABLE.interna > * > TR > :nth-child(2)"},
                        {"Column3", "TABLE.interna > * > TR > :nth-child(3)"}
                    },
                    [
                        RowSelector = "TABLE.interna > * > TR"
                    ]
                ),
                #"Cabeçalhos Promovidos" = Table.PromoteHeaders(
                    #"Tabela extraída de HTML", [PromoteAllScalars = true]
                ),
                #"Tipo Alterado" = Table.TransformColumnTypes(
                    #"Cabeçalhos Promovidos",
                    {{"Data", type date}, {"Dia da Semana", type text}, {"Feriado", type text}}
                )
            in
                #"Tipo Alterado",
        #"Função Personalizada Invocada" = Table.AddColumn(
            #"Tipo Alterado", "Feriados Nacionais", each FeriadosNacionais([Ano])
        ),
        #"Feriados Nacionais Expandido" = Table.ExpandTableColumn(
            #"Função Personalizada Invocada",
            "Feriados Nacionais",
            {"Data", "Feriado"},
            {"Feriados Nacionais.Data", "Feriados Nacionais.Feriado"}
        ),
        TiposAlterados = Table.TransformColumnTypes(
            #"Feriados Nacionais Expandido",
            {{"Feriados Nacionais.Data", type date}, {"Feriados Nacionais.Feriado", type text}}
        ),
        #"Outras Colunas Removidas1" = Table.SelectColumns(
            TiposAlterados, {"Feriados Nacionais.Data", "Feriados Nacionais.Feriado"}
        ),
        #"Consultas Mescladas1" = Table.NestedJoin(
            Consulta2, {"Data"}, #"Outras Colunas Removidas1", {"Feriados Nacionais.Data"}, "Feriados",
            JoinKind.LeftOuter
        ),
        #"Consulta2 Expandido" = Table.ExpandTableColumn(
            #"Consultas Mescladas1", "Feriados", {"Feriados Nacionais.Feriado"}, {"Feriados Nacionais.Feriado"}
        ),
        #"Personalização Adicionada11" = Table.AddColumn(
            #"Consulta2 Expandido",
            "Dia Útil",
            each if [DiaUtil] = 0 or [Feriados Nacionais.Feriado] <> null then 0 else 1,
            Int64.Type
        ),
        #"Colunas Removidas" = Table.RemoveColumns(#"Personalização Adicionada11", {"DiaUtil"}),
        #"Colunas Renomeadas" = Table.RenameColumns(#"Colunas Removidas", {{"Dia Útil", "DiaUtil"}}),
        TotalDiasUteisMes = Table.Group(
            #"Colunas Renomeadas", {"AnoMes"}, {{"Dias Úteis", each List.Sum([DiaUtil]), type number}}
        ),
        #"Consultas Mescladas" = Table.NestedJoin(
            #"Colunas Renomeadas", {"AnoMes"}, TotalDiasUteisMes, {"AnoMes"}, "Linhas Agrupadas", JoinKind.LeftOuter
        ),
        #"Linhas Agrupadas Expandido" = Table.ExpandTableColumn(
            #"Consultas Mescladas", "Linhas Agrupadas", {"Dias Úteis"}, {"Total Dias Úteis Mês"}
        ),
        #"Linhas Filtradas" = Table.SelectRows(#"Linhas Agrupadas Expandido", each ([DiaUtil] = 1)),
        #"Linhas Agrupadas2" = Table.Group(
            #"Linhas Filtradas",
            {"AnoMes"},
            {
                {
                    "Agrupamento",
                    each _,
                    type table [
                        Data = nullable date,
                        Dia = number,
                        DiaSemana = number,
                        NomeDiaSemana = text,
                        DiaUtil = number,
                        MesNum = number,
                        Mes = text,
                        Ano = number,
                        AnoMesNum = number,
                        AnoMes = text,
                        AnoSemestreNum = number,
                        AnoSemestre = text,
                        AnoQuadrimestreNum = number,
                        AnoQuadrimestre = text,
                        AnoTrimestreNum = number,
                        AnoTrimestre = text,
                        AnoBimestreNum = number,
                        AnoBimestre = text,
                        SemanaDoAno = number,
                        SemanaDoMes = number,
                        OrdemMes = number,
                        Total Dias Úteis Mês = nullable number
                    ]
                }
            }
        ),
        #"Personalização Adicionada9" = Table.AddColumn(
            #"Linhas Agrupadas2", "Personalizar", each Table.AddIndexColumn([Agrupamento], "Índice", 1)
        ),
        #"Colunas Removidas2" = Table.RemoveColumns(#"Personalização Adicionada9", {"Agrupamento"}),
        #"Personalizar Expandido" = Table.ExpandTableColumn(
            #"Colunas Removidas2", "Personalizar", {"Data", "Índice"}, {"Data", "Índice"}
        ),
        #"Linhas Filtradas1" = Table.SelectRows(#"Personalizar Expandido", each ([Índice] = N_Dia_Util_Do_Mes)),
        // #"Linhas Filtradas1" = Table.SelectRows(#"Personalizar Expandido", each ([Índice] = 5)),
        Personalizar1 = Table.NestedJoin(
            #"Linhas Filtradas1",
            {"AnoMes"},
            #"Linhas Agrupadas Expandido",
            {"AnoMes"},
            "Linhas Agrupadas",
            JoinKind.LeftOuter
        ),
        #"Linhas Agrupadas Expandido1" = Table.ExpandTableColumn(
            Personalizar1,
            "Linhas Agrupadas",
            {
                "Data",
                "Dia",
                "DiaSemana",
                "NomeDiaSemana",
                "DiaUtil",
                "MesNum",
                "Mes",
                "Ano",
                "AnoMesNum",
                "AnoMes",
                "AnoSemestreNum",
                "AnoSemestre",
                "AnoQuadrimestreNum",
                "AnoQuadrimestre",
                "AnoTrimestreNum",
                "AnoTrimestre",
                "AnoBimestreNum",
                "AnoBimestre",
                "SemanaDoAno",
                "SemanaDoMes",
                "OrdemMes",
                "Feriados Nacionais.Feriado",
                "Total Dias Úteis Mês"
            },
            {
                "Data.1",
                "Dia",
                "DiaSemana",
                "NomeDiaSemana",
                "DiaUtil",
                "MesNum",
                "Mes",
                "Ano",
                "AnoMesNum",
                "AnoMes.1",
                "AnoSemestreNum",
                "AnoSemestre",
                "AnoQuadrimestreNum",
                "AnoQuadrimestre",
                "AnoTrimestreNum",
                "AnoTrimestre",
                "AnoBimestreNum",
                "AnoBimestre",
                "SemanaDoAno",
                "SemanaDoMes",
                "OrdemMes",
                "Feriados",
                "Total Dias Úteis Mês"
            }
        ),
        #"Personalização Adicionada10" = Table.AddColumn(
            #"Linhas Agrupadas Expandido1",
            "N'ésimo Dia Útil do Mês",
            each if [Data] = [Data.1] then "SIM" else "NÃO",
            type text
        ),
        #"Colunas Removidas1" = Table.RemoveColumns(#"Personalização Adicionada10", {"AnoMes", "Data", "Índice"}),
        #"Colunas Renomeadas1" = Table.RenameColumns(
            #"Colunas Removidas1", {{"Data.1", "Data"}, {"AnoMes.1", "AnoMes"}}
        )
    in
        #"Colunas Renomeadas1"
