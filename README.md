## profile

Este módulo descreve todos os perfis (*profile*) que podem ser utilizado para construir os papéis (*role*) dos servidores

**Regras**:

* Um *perfil* (profile) sempre está relacionado com uma tecnologia (e.g. JBoss, httpd, postgres e etc) ou a configuração de uma tecnologia específica para um serviço (e.g. vhost do Portal Funpresp, datasource JBoss da aplicação XPTO ou banco de dados no PostgreSQL)

* Um *perfil* é parametrizado para suportar diferentes configurações de ambientes, diferentes versões de tecnologias e o reúso na composição de outros perfis de maior granularidade.

* Um *perfil* é uma abstração específica de tecnologia de um ou mais módulos, ou seja, ele não deve ter lógica de negócio, ele é apenas uma composição.
