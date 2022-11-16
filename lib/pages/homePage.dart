import 'package:contacts_app/dataBaseHandler/contatcsDataBaseHandler.dart';
import 'package:contacts_app/models/contactModel.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool confirmDelete = false;
  bool isDeleteAll = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  bool isUpdateMode = false;

  ContatcDataBaseHandler contatcDataBaseHandler = ContatcDataBaseHandler();

  // getAllData
  Future<List<ContactModel>> getAllData() async {
    List<ContactModel> allData = [];
    await contatcDataBaseHandler.getAllContactsFromDataBase().then((value) {
      allData = value;
    });
    return allData;
  }

  // insert Data To DataBase
  Future<void> insertData(BuildContext context) async {
    await contatcDataBaseHandler
        .insertContactToDataBase(
      ContactModel(name: nameController.text, number: numberController.text),
    )
        .then((value) {
      print('Data Saved');
      nameController.clear();
      numberController.clear();
      setState(() {});
      Navigator.pop(context);
    });
  }

// delet All Data
  deleteAllContatcs() async {
    await contatcDataBaseHandler.deleteAllContactsFromDataBase();
    setState(() {});
  }

// Delete contatc By Id
  deleteContact(int id) async {
    await contatcDataBaseHandler.deleteContactFromDataBaseByID(id);
  }

  // Update contatc
  updateContatc(ContactModel model, BuildContext context) async {
    await contatcDataBaseHandler
        .updateContactFromDataBaseById(
      ContactModel(
          name: nameController.text,
          number: numberController.text,
          id: model.id),
    )
        .then((value) {
      setState(() {});
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Contacts'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () {
              deleteAllContatcs();
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            label: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO : ADD Contacts
          customAlertDialog(context, null);
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FutureBuilder(
          future: getAllData(),
          builder: (BuildContext context,
              AsyncSnapshot<List<ContactModel>> snapshot) {
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return customContactTile(context,
                      id: snapshot.data![index].id!,
                      name: snapshot.data![index].name,
                      number: snapshot.data![index].number);
                },
              );
            } else {
              return const Center(
                  child: Text(
                ' No Contatcs',
                style: TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 35),
              ));
            }
          },
        ),
      ),
    );
  }

// Custom Contact Card
  Widget customContactTile(
    BuildContext context, {
    required String name,
    required String number,
    required int id,
  }) {
    return Card(
      elevation: 15,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.amber, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Dismissible(
        confirmDismiss: (vlaue) async {
          await deleteMessageDialog(context: context, id: id);
          return confirmDelete;
        },
        direction: DismissDirection.endToStart,
        key: UniqueKey(),
        background: Container(
          padding: const EdgeInsets.only(right: 10),
          color: Colors.red,
          child: const Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.delete),
          ),
        ),
        child: ListTile(
          title: Text(name),
          subtitle: Text(number),
          leading: CircleAvatar(
            child: Text(
                '${(name.isNotEmpty) ? name.substring(0, 1).toUpperCase() : ''}'),
          ),
          trailing: IconButton(
            onPressed: () {
              customAlertDialog(
                context,
                ContactModel(name: name, number: number, id: id),
              );
            },
            icon: const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }

// Delete Message
  Future deleteMessageDialog(
      {required BuildContext context, required int id}) async {
    await showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
          child: Container(
            height: MediaQuery.of(context).size.height / 8.5,
            child: Column(
              children: [
                const Text(
                  'Delete Message',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  (isDeleteAll)
                      ? 'Are you sure you want to delete All contacts'
                      : 'Are you sure you want to delete this contact',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO : delete just a contact
              deleteContact(id);
              confirmDelete = true;
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              // don't delete
              confirmDelete = false;
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
        ],
      ),
    );
    isDeleteAll = false;
  }

// Custom Widget For TextField
  Widget CustomTextField(String title, TextInputType keyBoardType,
      TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: keyBoardType,
      decoration: InputDecoration(
        label: Text('$title'),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.indigo,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(35),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

// Custom AlertDialog For ADD Or Update
  customAlertDialog(BuildContext context, ContactModel? model) {
    if (model != null) {
      // Update Mode
      isUpdateMode = true;
      nameController.text = model.name;
      numberController.text = model.number;
    } else {
      // Add Mode
      isUpdateMode = false;
      nameController.clear();
      numberController.clear();
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: Colors.indigo, width: 2),
            ),
            elevation: 15,
            content: Container(
              height: MediaQuery.of(context).size.height / 3,
              child: Column(
                children: [
                  Text(
                    (isUpdateMode) ? 'Update Contatc' : 'Add Contacts',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.indigo),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                      'Name', TextInputType.multiline, nameController),
                  const SizedBox(height: 8),
                  CustomTextField(
                      'Number', TextInputType.phone, numberController),
                  SizedBox(height: 15),
                  ElevatedButton(
                    // to Add Contact or Update Contact
                    onPressed: () => (isUpdateMode)
                        ? updateContatc(model!, context)
                        : insertData(context),
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        (isUpdateMode) ? 'Update' : 'Save',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side:
                              const BorderSide(color: Colors.indigo, width: 2),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
