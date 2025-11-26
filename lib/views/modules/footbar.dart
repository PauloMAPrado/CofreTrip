import 'package:flutter/material.dart';
// Seus imports de tela
import 'package:travelbox/views/home.dart';
import 'package:travelbox/views/account.dart';
import 'package:travelbox/views/premium.dart'; // Renomeando de Pro para Premium


class Footbarr extends StatefulWidget {
  // O Footbarr precisa saber qual tela está ativa no momento.
  // No entanto, para ser um componente reutilizável, 
  // ele deve ser implementado no Scaffold principal.
  const Footbarr({super.key});

  @override
  State<Footbarr> createState() => _FootbarrState();
}

class _FootbarrState extends State<Footbarr> {
  int _selectedIndex = 1; // 0: Conta, 1: Home (Default), 2: Premium

  // Lista de widgets (corpos das telas) para navegação por índice
  static final List<Widget> _widgetOptions = <Widget>[
    const Account(),
    // Nota: Home (a listagem de viagens) não aceita construtor simples se for o Dashboard.
    // Você precisará de um widget wrapper se Home exigir dados dinâmicos.
    const Home(), 
    const Pro(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Opcional: Navegar para a tela principal (se Footbarr não for o Scaffold)
    // No seu caso, você usará o Navigator.push para demonstração, 
    // mas o correto é trocar o corpo da tela pai.
    
    // COMO VOCÊ JÁ TINHA IMPLEMENTADO (Mas não é o ideal para UX):
    Widget targetWidget;
    if (index == 0) {
      targetWidget = const Account();
    } else if (index == 1) {
      targetWidget = const Home();
    } else {
      targetWidget = const Pro();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetWidget),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          activeIcon: Icon(Icons.account_circle),
          label: 'Conta',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star_border),
          activeIcon: Icon(Icons.star),
          label: 'Premium',
        ),
      ],
      currentIndex: _selectedIndex, // Marca o item ativo
      selectedItemColor: const Color(0xFF1E90FF), // Cor Primária
      unselectedItemColor: Colors.grey[600], // Cor Cinza para Inativo
      backgroundColor: const Color(0xFFF4F9FB), // Cor de Fundo do seu Container original
      type: BottomNavigationBarType.fixed, // Garante que todos os itens são exibidos
      onTap: _onItemTapped, // Função que lida com o clique
    );
  }
}