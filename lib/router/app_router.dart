import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/shop/home_screen.dart';
import '../screens/shop/catalog_screen.dart';
import '../screens/shop/wishlist_screen.dart';
import '../screens/shop/product_detail_screen.dart';
import '../screens/checkout/cart_screen.dart';
import '../screens/checkout/shipping_screen.dart';
import '../screens/checkout/payment_method_screen.dart';
import '../screens/checkout/confirmation_screen.dart';
import '../screens/checkout/receipt_screen.dart';
import '../screens/checkout/order_status_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/addresses_screen.dart';
import '../screens/profile/add_address_screen.dart';
import '../screens/profile/payment_methods_screen.dart';
import '../screens/profile/add_payment_method_screen.dart';
import '../screens/profile/history_screen.dart';
import '../screens/profile/support_screen.dart';
import '../screens/profile/faq_screen.dart';
import '../screens/profile/accessibility_screen.dart';
import '../screens/profile/survey_screen.dart';
import '../screens/components_showcase_screen.dart';
import '../models/address.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(path: '/onboarding', builder: (context, state) => OnboardingScreen()),
    GoRoute(path: '/', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    GoRoute(path: '/showcase', builder: (context, state) => ComponentsShowcaseScreen()),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/catalog', builder: (context, state) {
      final category = state.extra as String?;
      return CatalogScreen(initialCategory: category);
    }),
    GoRoute(path: '/wishlist', builder: (context, state) => WishlistScreen()),
    GoRoute(
      path: '/product_detail/:id', 
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailScreen(productId: id);
      }
    ),
    GoRoute(path: '/cart', builder: (context, state) => CartScreen()),
    GoRoute(path: '/shipping', builder: (context, state) => ShippingScreen()),
    GoRoute(path: '/payment_method', builder: (context, state) {
      final addressData = state.extra as dynamic;
      return PaymentMethodScreen(addressData: addressData);
    }),
    GoRoute(path: '/confirmation', builder: (context, state) {
      final checkoutData = state.extra as dynamic;
      return ConfirmationScreen(checkoutData: checkoutData);
    }),
    GoRoute(
      path: '/receipt', 
      builder: (context, state) {
        final fromCheckout = state.extra as bool? ?? true;
        return ReceiptScreen(fromCheckout: fromCheckout);
      }
    ),
    GoRoute(
      path: '/receipt/:id', 
      builder: (context, state) {
        final id = state.pathParameters['id'];
        final fromCheckout = state.extra as bool? ?? false;
        return ReceiptScreen(orderId: id, fromCheckout: fromCheckout);
      }
    ),
    GoRoute(path: '/order_status', builder: (context, state) => OrderStatusScreen()),
    GoRoute(
      path: '/order_status/:id', 
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return OrderStatusScreen(orderId: id);
      }
    ),
    GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
    GoRoute(path: '/addresses', builder: (context, state) => AddressesScreen()),
    GoRoute(path: '/add_address', builder: (context, state) {
      final addressToEdit = state.extra as Address?;
      return AddAddressScreen(addressToEdit: addressToEdit);
    }),
    GoRoute(path: '/payment_methods', builder: (context, state) => PaymentMethodsScreen()),
    GoRoute(path: '/add_payment_method', builder: (context, state) => AddPaymentMethodScreen()),
    GoRoute(path: '/history', builder: (context, state) => HistoryScreen()),
    GoRoute(path: '/support', builder: (context, state) => SupportScreen()),
    GoRoute(path: '/faq', builder: (context, state) => FaqScreen()),
    GoRoute(path: '/accessibility', builder: (context, state) => AccessibilityScreen()),
    GoRoute(
      path: '/survey', 
      builder: (context, state) => SurveyScreen()
    ),
    GoRoute(
      path: '/survey/:id', 
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return SurveyScreen(orderId: id);
      }
    ),
  ],
);
