/* 1. Liste o nome dos usuários que não cadastraram nenhuma medição, seja ela pluviométrica ou de cota diária. */

SELECT u.nome
FROM Usuario u
WHERE u.idMatricula in(
    SELECT u.idMatricula
        FROM Usuario u LEFT OUTER JOIN  Medicao_Cota_Diaria mcd ON 
             u.idMatricula = mcd.idMatricula
            WHERE mcd.idMedicaoDiaria is NULL
        INTERSECT 
    SELECT u.idMatricula
        FROM Usuario u LEFT OUTER JOIN  MedicaoPluviometrica mp ON 
             u.idMatricula = mp.idUsuario
            WHERE mp.idMedicao is NULL 
);

/* 2. Crie uma visão que liste os valores de chuva diários medidos para o açude de Bodocongó.*/

CREATE OR REPLACE VIEW VALORES_DIARIOS_BODOCONGO(VALORES_CHUVA) AS   
    SELECT valorChuva
    FROM DiaMedPluviometrica diaMed, MedicaoPluviometrica med, PostoPluviometrico posto, Contribui_Posto_Acude cpa, Acude a
    WHERE diaMed.idMedicao = med.idMedicao AND 
          posto.idPostoPluviometrico = med.idMedicao AND
          cpa.idPostoPluviometrico = posto.idPostoPluviometrico AND
          cpa.idAcude = a.idAcude AND
          a.nome = 'Bodocongó';
          
/* Consulta na view para mostrar sua criação*/
SELECT *
FROM VALORES_DIARIOS_BODOCONGO;    

/*3. Crie uma visão que liste os nomes de todas as estações de qualidade que já realizaram medições para rios de Pernambuco, bem como o nome do rio.*/

CREATE OR REPLACE VIEW ESTACOES_RIOS_PERNAMBUCO(estacao_PE,nome_PE) AS 
    SELECT DISTINCT eq.nome, r.nome
    FROM Bacia b, Rio r, PostoPluviometrico pp, EstacaoQualidade eq
    WHERE( pp.estado = 'Pernambuco' AND
           pp.idBacia = b.idBacia AND
           b.idBacia = r.idBacia AND
           eq.idRio = r.idRio);
           
/* Consulta na view para mostrar sua criação*/
SELECT *
FROM ESTACOES_RIOS_PERNAMBUCO;

/* 4. Liste os nomes dos postos pluviométricos e seus estados, agrupados pelo nome do estado.*/

SELECT pp.nome, pp.estado
FROM PostoPluviometrico pp
ORDER BY pp.estado;


/* 5. Liste os valores de ph e o nome do açude, agrupadas por açude.*/

SELECT md.ph, a.nome
FROM Acude a, MedicaoRio md
WHERE md.idEstacaoQualidade in(
    SELECT idEstacaoQualidade
    FROM EstacaoQualidade eq
    WHERE eq.idAcude = a.idAcude)
    ORDER BY a.nome;

/* 6. Liste o nome das bacias, sua área e perímetro, ordenadas pelo tamanho da área e pelo perímetro de forma crescente.*/

SELECT idBacia, nome, area, perimetro
FROM Bacia
ORDER BY area, perimetro;

/* 7. Liste os valores de alcalinidade pro açude de Bodocongó, ordenadas de forma decrescente.*/

SELECT alcalinidade AS alcalinidade_Bodocongo
    FROM MedicaoRio JOIN (
    SELECT idEstacaoQualidade
    FROM EstacaoQualidade E
    WHERE E.idAcude =
        (SELECT idAcude
        FROM Acude a
        WHERE a.nome = 'Bodocongó'))
    USING (idEstacaoQualidade)
ORDER BY alcalinidade DESC;

/*8 e 9 No script de inserções. */

/* 10. Liste os valores de DBO medidos para o rio Amazonas entre os dias 02/11/2017 e 02/01/2018.*/

SELECT DBO
FROM MedicaoRio mr, Rio r, EstacaoQualidade eq
WHERE mr.idEstacaoQualidade = eq.idEstacaoQualidade AND eq.idRio = r.idRio AND
    r.nome = 'Rio Amazonas' AND mr.data BETWEEN '11-02-2017' AND '01-02-2018';

/* 11. Qual o maior valor da cota atual do açude Bodocongó entre os dias 01/01/2018 e 01/02/2018?*/

SELECT MAX(cotaAtual)
    FROM Medicao_Cota_Diaria mcd, Acude a
    WHERE a.nome = 'Bodocongó' AND
          mcd.idAcude = a.idAcude AND
          mcd.data BETWEEN '01-01-2018'AND '02-01-2018';

/*12. Qual foi o valor total de chuvas no açude de Coremas pro mês de Janeiro/2018?*/
SELECT SUM(dp.valorChuva)
FROM DiaMedPluviometrica dp, MedicaoPluviometrica mp, PostoPluviometrico pp, Acude a, Contribui_Posto_Acude cpa
WHERE (dp.idMedicao = mp.idMedicao AND mp.idPostoPluviometrico = pp.idPostoPluviometrico AND pp.idPostoPluviometrico = cpa.idPostoPluviometrico AND
      cpa.idAcude = a.idAcude AND a.nome = 'Coremas' AND dp.data BETWEEN '01-01-2018' AND '01-31-2018');

/* 13. Qual o nível médio de oxigênio medido no mês de novembro pro açude de Coremas?*/

SELECT AVG(oxigenio)
FROM MedicaoRio mr, Acude a, EstacaoQualidade eq
WHERE mr.idEstacaoQualidade = eq.idEstacaoQualidade AND eq.idAcude = a.idAcude AND
    a.nome = 'Coremas' AND mr.data BETWEEN '11-01-2017' AND '11-30-2017';

/* 14. Qual a bacia com a menor área?*/
SELECT *
FROM Bacia
    WHERE area = (SELECT MIN(area) 
    FROM Bacia);

/* 15. Qual o nome do usuário que mais realizou medições de cotas diárias, e quantas foram?  */
SELECT nome, (SELECT *
    FROM (
    SELECT MAX(COUNT(idMatricula))
    FROM Medicao_Cota_Diaria
    GROUP BY idMatricula)) as frequencia
FROM Usuario u 
WHERE u.idMatricula = 
 
(SELECT idMatricula
    FROM (
    SELECT idMatricula,COUNT(idMatricula)
    FROM Medicao_Cota_Diaria
    GROUP BY idMatricula ORDER BY COUNT(idMatricula) DESC)
where rownum = 1);  
