// screens/app_bar_menu/pricing/pricing_page.dart

import 'package:flutter/material.dart';
import '../../premium_effects.dart';
import '../../button_buldge.dart';
// import 'transition_animations.dart';
import '../../animations/pendulum_animation.dart';

enum BillingCycle { monthly, yearly }

class PricingPlan {
  final String       name;
  final String       tagline;
  final double       monthlyPrice;          // in INR (₹)
  final double       yearlyDiscountPct;      // e.g. 0.20 == 20% off monthly rate
  final List<String> features;
  final bool         highlighted;
  final bool         isAddOn;
  final IconData     icon;

  const PricingPlan({
    required this.name,
    required this.tagline,
    required this.monthlyPrice,
    required this.features,
    required this.icon,
    this.yearlyDiscountPct = 0.20,
    this.highlighted = false,
    this.isAddOn = false,
  });

  /// Effective price per month for the given billing cycle.
  /// Yearly price is calculated automatically — no need to hardcode it.
  double priceFor(BillingCycle cycle) {
    if (monthlyPrice == 0) return 0;
    if (cycle == BillingCycle.monthly) return monthlyPrice;
    final discounted = monthlyPrice * (1 - yearlyDiscountPct);
    return discounted;
  }

  /// Total billed amount for the cycle (yearly is charged as 12x the
  /// discounted monthly rate, upfront).
  double totalFor(BillingCycle cycle) {
    final perMonth = priceFor(cycle);
    return cycle == BillingCycle.yearly ? perMonth * 12 : perMonth;
  }
}

const _plans = <PricingPlan>[
  PricingPlan(
    name:         'Free',
    tagline:      'Get started with QuantMessage',
    monthlyPrice: 0,
    icon:         Icons.bolt_outlined,
    features: [
      'Access to QuantMessage free tier',
      'Limited messages / month',
      'Community support',
      'Web + Mobile access',
      'Ads supported',
    ],
  ),
  PricingPlan(
    name:         'Pro',
    tagline:      'For individuals who want more',
    monthlyPrice: 150,
    icon:         Icons.workspace_premium_outlined,
    features: [
      'Full access to QuantMessage',
      'Higher message limits',
      'Priority response speed',
      'Email support',
      'Reduced ads',
    ],
  ),
  PricingPlan(
    name:         'Prime',
    tagline:      'For power users who need it all',
    monthlyPrice: 250,
    icon:         Icons.auto_awesome_outlined,
    highlighted:  true,
    features: [
      'Everything in Pro',
      'Unlimited QuantMessage access',
      'Advanced features & tools',
      'Faster priority support',
      'No ads included',
    ],
  ),
  PricingPlan(
    name:         'Enterprise',
    tagline:      'For teams and organizations',
    monthlyPrice: 1000,
    icon:         Icons.groups_2_outlined,
    features: [
      'Everything in Prime',
      'Team / multi-seat access',
      'Dedicated account manager',
      'Custom integrations',
      'SLA-backed support',
      'No ads included',
    ],
  ),
];

const _addOnPlan = PricingPlan(
  name:         'No Ads',
  tagline:      'Remove ads from any plan',
  monthlyPrice: 50,
  icon:         Icons.block_outlined,
  isAddOn:      true,
  features: [
    'Removes all ads',
    'Stacks with Free or Pro plan',
    'Cancel anytime',
  ],
);

class PricingPage extends StatefulWidget {
  const PricingPage({Key? key}) : super(key: key);

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage>
    with SingleTickerProviderStateMixin {

  late final AnimationController _heroCtrl;
  late final Animation<double>   _heroFade;
  late final Animation<Offset>   _heroSlide;

  BillingCycle _cycle    = BillingCycle.monthly;
  PricingPlan  _selected = _plans[2]; // default to Prime (highlighted plan)
  bool         _addOnSelected = false;

  final GlobalKey _bodyKey = GlobalKey();
  Key _swapKey = const ValueKey('plans_grid_v1');

  // animation controller
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heroFade = CurvedAnimation(
      parent: _heroCtrl,
      curve: Curves.easeOut,
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end:   Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroCtrl,
      curve: Curves.easeOutCubic,
    ));

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _heroCtrl.forward();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _selectPlan(PricingPlan plan) {
    if (_selected.name == plan.name) return;
    setState(() {
      _selected = plan;
      _swapKey  = ValueKey('plans_grid_${plan.name}_${DateTime.now().microsecondsSinceEpoch}');
    });
  }

  void _toggleAddOn() {
    setState(() => _addOnSelected = !_addOnSelected);
  }

  double get _totalDue {
    final base = _selected.totalFor(_cycle);
    final addOn = _addOnSelected ? _addOnPlan.totalFor(_cycle) : 0.0;
    return base + addOn;
  }

  void _onContinue() {
    final cycleLabel = _cycle == BillingCycle.monthly ? 'monthly' : 'yearly';
    final addOnLabel = _addOnSelected ? ' + No Ads' : '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Continuing with ${_selected.name}$addOnLabel plan ($cycleLabel) '
              '— ₹${_totalDue.toStringAsFixed(0)} ${_cycle == BillingCycle.yearly ? "/ year" : "/ month"}.',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1A1F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW  = MediaQuery.of(context).size.width;
    final isMobile = screenW < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(isMobile),
              const SizedBox(height: 40),
              _buildBillingToggle(),
              const SizedBox(height: 40),
              _buildPlansGrid(isMobile),
              const SizedBox(height: 28),
              _buildAddOnCard(isMobile),
              const SizedBox(height: 40),
              _buildContinueBar(isMobile),
              const SizedBox(height: 40),
              _buildFooterNote(),
            ],
          ),
        ),
      ),
    );
  }

  // header

  Widget _buildHeader(bool isMobile) {
    return FadeTransition(
      opacity: _heroFade,
      child: SlideTransition(
        position: _heroSlide,
        child: Column(
          children: [
            const PendulumAnimation(size: 72, color: Color(0xFF0D0D0D)),
            const SizedBox(height: 28),
            Text(
              '< Pricing >',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily:    '__copernicus_669e4a',
                fontSize:      isMobile ? 34 : 56,
                fontWeight:    FontWeight.w800,
                color:         const Color(0xFF0D0D0D),
                height:        1.1,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 18),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Text(
                'Simple, transparent pricing for QuantMessage. Start free, upgrade anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily:  'Inter',
                  fontSize:    isMobile ? 15 : 18,
                  fontWeight:  FontWeight.w400,
                  color:       const Color(0xFF0D0D0D).withOpacity(0.55),
                  height:      1.5,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: const Color(0xFF1A1A1A).withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleChip(BillingCycle.monthly, 'Monthly'),
          _buildToggleChip(BillingCycle.yearly,  'Yearly  • save 20%'),
        ],
      ),
    );
  }

  Widget _buildToggleChip(BillingCycle cycle, String label) {
    final selected = _cycle == cycle;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _cycle = cycle),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0D0D0D) : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily:  'Inter',
              fontSize:    13,
              fontWeight:  FontWeight.w600,
              color:       selected ? Colors.white : const Color(0xFF0D0D0D).withOpacity(0.7),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlansGrid(bool isMobile) {
    final grid = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (isMobile) {
          return Column(
            children: _plans
                .map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _PlanCard(
                plan:        p,
                cycle:       _cycle,
                isSelected:  _selected.name == p.name,
                onSelect:    () => _selectPlan(p),
                bgController: _bgController,
                fullWidth:   width,
              ),
            ))
                .toList(),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _plans.map((p) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: _PlanCard(
                  plan:        p,
                  cycle:       _cycle,
                  isSelected:  _selected.name == p.name,
                  onSelect:    () => _selectPlan(p),
                  bgController: _bgController,
                ),
              ),
            );
          }).toList(),
        );
      },
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve:  Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: _swapKey, child: grid),
    );
  }

  Widget _buildAddOnCard(bool isMobile) {
    final price = _addOnPlan.priceFor(_cycle);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _toggleAddOn,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _addOnSelected
                    ? const Color(0xFFFF8A50)
                    : const Color(0xFF1A1A1A).withOpacity(0.08),
                width: _addOnSelected ? 1.6 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D).withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.block_outlined, size: 17, color: Color(0xFF0D0D0D)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No Ads add-on',
                        style: TextStyle(
                          fontFamily:  'Inter',
                          fontSize:    14.5,
                          fontWeight:  FontWeight.w700,
                          color:       Color(0xFF0D0D0D),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Remove ads from your plan',
                        style: TextStyle(
                          fontFamily:  'Inter',
                          fontSize:    12.5,
                          fontWeight:  FontWeight.w400,
                          color:       const Color(0xFF0D0D0D).withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  price == 0 ? 'Free' : '₹${price.toStringAsFixed(0)} / mo',
                  style: const TextStyle(
                    fontFamily:  'Inter',
                    fontSize:    14,
                    fontWeight:  FontWeight.w700,
                    color:       Color(0xFF0D0D0D),
                  ),
                ),
                const SizedBox(width: 14),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _addOnSelected ? const Color(0xFFFF8A50) : Colors.transparent,
                    border: Border.all(
                      color: _addOnSelected
                          ? const Color(0xFFFF8A50)
                          : const Color(0xFF0D0D0D).withOpacity(0.25),
                      width: 1.4,
                    ),
                  ),
                  child: _addOnSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueBar(bool isMobile) {
    final cycleSuffix = _cycle == BillingCycle.monthly ? '/ mo' : '/ yr';

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        ButtonBulge(
          child: AuraButton(
            onPressed: _onContinue,
            auraController: _bgController,
            width: isMobile ? 220 : 200,
            height: 46,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize:      14,
                      fontWeight:    FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: const Color(0xFF1A1A1A).withOpacity(0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 16, color: Color(0xFF0D0D0D)),
              const SizedBox(width: 8),
              Text(
                'Selected: ${_selected.name}'
                    '${_addOnSelected ? ' + No Ads' : ''}'
                    '  •  ₹${_totalDue.toStringAsFixed(0)} $cycleSuffix',
                style: const TextStyle(
                  fontFamily:  'Inter',
                  fontSize:    13,
                  fontWeight:  FontWeight.w600,
                  color:       Color(0xFF0D0D0D),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterNote() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Text(
        'Prices shown in INR (₹). Yearly billing is charged upfront at a 20% '
            'discount versus the monthly rate. Cancel any time from your account settings.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily:  'Inter',
          fontSize:    12.5,
          fontWeight:  FontWeight.w400,
          color:       const Color(0xFF0D0D0D).withOpacity(0.45),
          height:      1.5,
        ),
      ),
    );
  }
}

class _PlanCard extends StatefulWidget {
  final PricingPlan         plan;
  final BillingCycle        cycle;
  final bool                isSelected;
  final VoidCallback        onSelect;
  final AnimationController bgController;
  final double?             fullWidth;

  const _PlanCard({
    required this.plan,
    required this.cycle,
    required this.isSelected,
    required this.onSelect,
    required this.bgController,
    this.fullWidth,
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.plan.highlighted;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: highlighted ? const Color(0xFF0D0D0D) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFFFF8A50)
                  : const Color(0xFF1A1A1A).withOpacity(_hovered ? 0.18 : 0.08),
              width: widget.isSelected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovered ? 0.10 : 0.05),
                blurRadius: _hovered ? 28 : 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(highlighted),
              const SizedBox(height: 18),
              _buildPrice(highlighted),
              const SizedBox(height: 22),
              const Divider(
                height: 1,
                color: Color(0x1A1A1A1A),
              ),
              const SizedBox(height: 18),
              _buildFeatures(highlighted),
              const SizedBox(height: 26),
              _buildCTA(highlighted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool highlighted) {
    final fg = highlighted ? Colors.white : const Color(0xFF0D0D0D);
    final sub = (highlighted ? Colors.white : const Color(0xFF0D0D0D)).withOpacity(0.6);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width:  38,
          height: 38,
          decoration: BoxDecoration(
            color: highlighted
                ? Colors.white.withOpacity(0.08)
                : const Color(0xFF0D0D0D).withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.plan.icon, color: fg, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.plan.name,
                style: TextStyle(
                  fontFamily:    '__copernicus_669e4a',
                  fontSize:      20,
                  fontWeight:    FontWeight.w700,
                  color:         fg,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.plan.tagline,
                style: TextStyle(
                  fontFamily:  'Inter',
                  fontSize:    12,
                  fontWeight:  FontWeight.w400,
                  color:       sub,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        if (highlighted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A50),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Text(
              'POPULAR',
              style: TextStyle(
                fontFamily:  'Inter',
                fontSize:    9,
                fontWeight:  FontWeight.w700,
                color:       Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPrice(bool highlighted) {
    final price  = widget.plan.priceFor(widget.cycle);
    final fg     = highlighted ? Colors.white : const Color(0xFF0D0D0D);
    final sub    = (highlighted ? Colors.white : const Color(0xFF0D0D0D)).withOpacity(0.55);
    final isFree = price == 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          isFree ? 'Free' : '₹${price.toStringAsFixed(0)}',
          style: TextStyle(
            fontFamily:    '__copernicus_669e4a',
            fontSize:      38,
            fontWeight:    FontWeight.w800,
            color:         fg,
            height:        1.0,
            letterSpacing: -1.0,
          ),
        ),
        if (!isFree) ...[
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              ' / mo',
              style: TextStyle(
                fontFamily:  'Inter',
                fontSize:    13,
                fontWeight:  FontWeight.w500,
                color:       sub,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (!isFree && widget.cycle == BillingCycle.yearly)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80).withOpacity(0.15),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Text(
              '−20%',
              style: TextStyle(
                fontFamily:  'Inter',
                fontSize:    10,
                fontWeight:  FontWeight.w700,
                color:       Color(0xFF4ADE80),
                letterSpacing: 0.4,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatures(bool highlighted) {
    final fg = highlighted ? Colors.white : const Color(0xFF0D0D0D);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.plan.features.map((f) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check,
                size:  16,
                color: highlighted ? const Color(0xFFFF8A50) : const Color(0xFF0D0D0D),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  f,
                  style: TextStyle(
                    fontFamily:  'Inter',
                    fontSize:    13.5,
                    fontWeight:  FontWeight.w400,
                    color:       fg.withOpacity(0.85),
                    height:      1.45,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCTA(bool highlighted) {
    if (highlighted) {
      return Center(
        child: ButtonBulge(
          child: AuraButton(
            onPressed: widget.onSelect,
            auraController: widget.bgController,
            width: 180, height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    widget.isSelected ? 'Selected' : 'Choose ${widget.plan.name}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(widget.isSelected ? Icons.check : Icons.arrow_forward, size: 14),
              ],
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: OutlinedButton(
          onPressed: widget.onSelect,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: const Color(0xFF0D0D0D).withOpacity(_hovered ? 1.0 : 0.28),
              width: 1.2,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            backgroundColor:
            _hovered ? const Color(0xFF0D0D0D) : Colors.transparent,
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily:  'Inter',
              fontSize:    13,
              fontWeight:  FontWeight.w600,
              color:       _hovered ? Colors.white : const Color(0xFF0D0D0D),
              letterSpacing: 0.4,
            ),
            child: Text(
              widget.isSelected ? 'Selected' : 'Choose ${widget.plan.name}',
            ),
          ),
        ),
      ),
    );
  }
}