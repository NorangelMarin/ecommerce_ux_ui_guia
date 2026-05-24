import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/product_card.dart';
import '../widgets/custom_alert.dart';
import '../widgets/top_navigation_bar.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/checkout_stepper.dart';
import 'package:easy_localization/easy_localization.dart';

class ComponentsShowcaseScreen extends StatefulWidget {
  const ComponentsShowcaseScreen({super.key});

  @override
  State<ComponentsShowcaseScreen> createState() => _ComponentsShowcaseScreenState();
}

class _ComponentsShowcaseScreenState extends State<ComponentsShowcaseScreen> {
  int _currentIndex = 0;

  void _showAlert(BuildContext context, AlertType type, String message) {
    showDialog(
      context: context,
      builder: (context) => CustomAlert(type: type, message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: TopNavigationBar(title: 'componentes_ui'.tr()),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tarjetas (Cards)', style: theme.textTheme.displayMedium),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ProductCard(
                  type: CardType.vertical,
                  title: 'producto_de_prueba'.tr(),
                  price: '\$ 24,99',
                ),
              ],
            ),
            SizedBox(height: 16),
            ProductCard(
              type: CardType.horizontal,
              title: 'producto_horizontal'.tr(),
              price: '\$ 15,00',
            ),
            SizedBox(height: 16),
            ProductCard(
              type: CardType.carrito,
              title: 'producto_en_carrito'.tr(),
              price: '\$ 10,00',
              quantity: 2,
            ),
            SizedBox(height: 32),

            Text('Progreso (Stepper)', style: theme.textTheme.displayMedium),
            CheckoutStepper(currentStep: 2),
            SizedBox(height: 32),

            Text('Modales / Alertas', style: theme.textTheme.displayMedium),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showAlert(context, AlertType.exito, 'La operación fue un éxito.'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text('Éxito', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => _showAlert(context, AlertType.advertencia, 'Revisa los datos ingresados.'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text('Aviso', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => _showAlert(context, AlertType.error, 'Hubo un error al procesar.'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Error', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 32),

            Text('Botones', style: theme.textTheme.displayMedium),
            SizedBox(height: 16),
            CustomButton(text: 'Principal', onPressed: () {}),
            SizedBox(height: 8),
            CustomButton(text: 'Alternativo', type: ButtonType.alternativo, onPressed: () {}),
            SizedBox(height: 8),
            CustomButton(text: 'Inactivo', type: ButtonType.inactivo),
            SizedBox(height: 32),

            Text('Campos de Texto', style: theme.textTheme.displayMedium),
            SizedBox(height: 16),
            CustomTextField(label: 'ejemplo_de_input'.tr(), placeholder: 'Escribe aquí...'),
            SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

