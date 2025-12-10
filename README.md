# ✈️ CofreTrip: Seu Planejamento Financeiro de Viagens em Grupo (Aplicativo Flutter)

> **Slogan:** **Economize. Explore. Viva.** Gerencie metas e despesas de viagem de forma colaborativa e transparente.

**Status do Projeto:** 🟢 **Finalizado (V1.0)**

**CofreTrip** é um aplicativo mobile colaborativo desenvolvido em **Flutter**, projetado para simplificar a complexidade do planejamento financeiro de viagens em grupo. Nosso foco é duplo: **acompanhar a meta de economia** (controle de caixa) e **gerenciar despesas internas** de forma transparente, com um sistema de *Splitwise* inteligente e integrado.

---

## ✨ Funcionalidades em Destaque

Seu aplicativo resolve os maiores dilemas de viagens em grupo:

* ### Controle de Metas e Arrecadação 🎯
    * Crie **Cofres de economia compartilhados** com valores alvo e datas de início/fim.
    * Acompanhe o progresso da **arrecadação em tempo real** e visualize o histórico detalhado de **Contribuições** de cada membro.
    * Cálculo de **Sugestão Mensal de Contribuição** (baseado no saldo restante e prazo até a viagem).

* ### Gestão de Gastos e Dívidas (Splitwise Avançado) 🧾
    * Registro rápido de **Despesas Reais** e **Planejamento de Orçamento** (despesas estimadas).
    * **Divisão Dinâmica de Gastos:** O aplicativo calcula automaticamente o saldo devedor/credor de cada participante, mesmo quando o gasto não é dividido igualmente entre todos.
    * **Algoritmo de Simplificação de Dívida:** As dívidas complexas são reduzidas ao **número mínimo de transações** necessárias para zerar o grupo (e.g., A paga B, em vez de A paga C, C paga D, e D paga B).

* ### Liquidação e Fechamento de Contas ✅
    * **Saldos e Acertos Líquidos:** Tela dedicada para visualização do saldo final (quem deve o quê a quem), facilitando a **liquidação das dívidas** de forma justa.
    * **Pagamento Parcial:** Suporte ao registro de pagamentos parciais, atualizando o saldo restante.
    * **Fechamento Automático:** O cofre **bloqueia novas despesas/contribuições** automaticamente após a data da viagem, permitindo apenas a **quitação de saldos remanescentes**.

* ### Organização do Grupo 🤝
    * **Gerenciamento de Membros:** Convite de usuários e gestão de permissões de acesso ao cofre.

---

## 💻 Arquitetura e Tecnologias

Nosso projeto segue uma arquitetura baseada em Providers.

| Categoria | Tecnologia | Função |
| :--- | :--- | :--- |
| **Linguagem Principal** | **Dart** (via Flutter) | Linguagem de programação moderna e tipada. |
| **Frontend/UI** | **Flutter** | Desenvolvimento cross-platform (Android/iOS). |
| **Estado/Lógica** | **Provider** (`ChangeNotifier`) | Centralização da lógica de negócios (Stores). |
| **Backend/BD** | **Firebase Firestore** | **Banco de Dados NoSQL** para sincronização de dados em tempo real. |
| **Autenticação** | **Firebase Auth** | Serviço de autenticação, login e segurança. |
| **Utils** | **intl** / **Input Formatters** | Formatação de moeda (R$) e máscaras de entrada. |

---

## 👥 Informações do Projeto e Colaboradores

| Categoria | Detalhe |
| :--- | :--- |
| **Desenvolvedores** 🧑‍💻 | Sara Luiz de Farias, Paulo Prado, Luís Fernando Naves, Ítalo Guimarães |
| **Instituição** 🏫 | IF Goiano - Campus Ceres |
| **Módulos Abrangidos** 📚 | Prática de Desenvolvimento de Software, Marketing e Programação para Dispositivos Móveis. |
| **Professores Orientadores** 👨‍🏫 | Rafael Divino Ferreira Feitosa, Maryele Lazara Rezende, Paulo Henrique Rodrigues Araujo |

---

### 📥 Como Rodar o Projeto

*(Incluir aqui as instruções de setup do Firebase e os comandos `flutter pub get` / `flutter run`)*
