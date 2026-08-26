# Estrutura do Banco de Dados
O banco é estruturado em torno das seguintes entidades:<br/>

`organization` — a unidade fitness cadastrada no sistema (ex.: LCKR Training Club), preparando o sistema para eventualmente atender mais de uma unidade.<br/>
`users` — contas de acesso ao sistema, usadas pela secretaria e pela administração.<br/>
`coaches` — cadastro dos professores, vinculados a uma organization.<br/>
`lessons` — aulas ministradas, vinculadas a um coach.<br/>
`payments` — pagamentos gerados a partir das aulas registradas.<br/>
`coach_salary_history` — histórico de valores pagos por aula a cada `coach`, permitindo rastrear mudanças de valor ao longo do tempo sem sobrescrever o registro anterior.<br/>

# Modelo lógico e relacional
<img src="modelo-banco.jpeg">