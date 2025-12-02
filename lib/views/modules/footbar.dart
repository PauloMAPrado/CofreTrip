import 'package:flutter/material.dart';
// Seus imports de tela
import 'package:travelbox/views/home.dart';
import 'package:travelbox/views/account.dart';
import 'package:travelbox/views/premium.dart'; 
import 'package:travelbox/views/login.dart'; // Adicionado, caso precise logar

class Footbarr extends StatefulWidget {
  const Footbarr({super.key});

  @override
  State<Footbarr> createState() => _FootbarrState();
}

class _FootbarrState extends State<Footbarr> {
  // Nota: Em um aplicativo real, este valor deve ser dinâmico (com base na rota atual).
  int _selectedIndex = 1; // 0: Conta, 1: Home (Default), 2: Premium


  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // Se já estamos na Home, forçamos um reset para o topo da pilha para recarregar
      if (index == 1) {
          _navigateToTarget(const Home(), index);
      }
      return;
    }
    
    // 1. Atualiza o índice para mudar o ícone
    setState(() {
      _selectedIndex = index;
    });

    // 2. Define a tela de destino
    Widget targetWidget;
    if (index == 0) {
      targetWidget = Account(); // Sem const
    } else if (index == 1) {
      targetWidget = Home(); // Sem const
    } else {
      targetWidget = Pro(); // Sem const
    }

    // 3. Navegação
    _navigateToTarget(targetWidget, index);
  }

  void _navigateToTarget(Widget targetWidget, int index) {
    // 🎯 A CORREÇÃO FINAL: Push and Remove Until
    // Isso limpa a pilha de navegação e força o widget de destino a ser reconstruído, 
    // disparando o didChangeDependencies para buscar novos dados.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => targetWidget),
      (Route<dynamic> route) => false, // Remove TUDO da pilha, exceto a tela de destino
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
      currentIndex: _selectedIndex, 
      selectedItemColor: const Color(0xFF1E90FF), 
      unselectedItemColor: Colors.grey[600],
      backgroundColor: const Color(0xFFF4F9FB),
      type: BottomNavigationBarType.fixed, 
      onTap: _onItemTapped,
    );
  }
}