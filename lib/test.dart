if (success) {
Provider.of<AuthProvider>(context, listen: false).setLoggedIn(true);
context.go('/');
}
