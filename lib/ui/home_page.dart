import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A a Z"),
                value: OrderOptions.orderaz,
              ),
              PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z a A"),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: contacts.length,
          itemBuilder: (context, index){
            return _contactCard(context, index);
          }),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null ?
                        FileImage(File(contacts[index].img)) :
                        AssetImage("images/person.png"),
                    fit: BoxFit.cover
                  ),
                ),
              ),
              SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contacts[index].name ?? "",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,),
                  ),
                  Text(contacts[index].email ?? "",
                    style: TextStyle(fontSize: 18,),
                  ),
                  Text(contacts[index].phone ?? "",
                    style: TextStyle(fontSize: 18,),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOption(context, index);
      },
    );
  }

  void _showOption(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Center(
                        child: Text("Novo",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      contentPadding: EdgeInsets.all(10),
                      onTap: () {
                        Navigator.pop(context);
                        _showContactPage();
                      },
                    ),
                    ListTile(
                      title: Center(
                        child: Text("Ligar",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      contentPadding: EdgeInsets.all(10),
                      onTap: () {
                        Navigator.pop(context);
                        launch("tel:${contacts[index].phone}");
                      },
                    ),
                    ListTile(
                      title: Center(
                        child: Text("Editar",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      contentPadding: EdgeInsets.all(10),
                      onTap: () {
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      },
                    ),
                    ListTile(
                      title: Center(
                        child: Text("Excluir",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      contentPadding: EdgeInsets.all(10),
                      onTap: () {
                        helper.deleteContact(contacts[index].id);
                        setState(() {
                          contacts.removeAt(index);
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            });
      }
    );
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact))
    );
    if (recContact != null) {
      print(recContact);
      if (contact != null) {
        await helper.updateContact(recContact);
        print("atualizou" + contact.toString());
      } else {
        await helper.saveContact(recContact);
        print("salvou" + contact.toString());
      }
      _getAllContacts();
    }
  }

  _orderList(OrderOptions result) {
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a, b ){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b ){
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }
}
