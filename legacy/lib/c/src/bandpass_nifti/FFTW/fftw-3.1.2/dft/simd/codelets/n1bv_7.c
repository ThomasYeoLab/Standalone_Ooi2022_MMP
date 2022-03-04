/*
 * Copyright (c) 2003, 2006 Matteo Frigo
 * Copyright (c) 2003, 2006 Massachusetts Institute of Technology
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

/* This file was automatically generated --- DO NOT EDIT */
/* Generated on Sat Jul  1 14:27:10 EDT 2006 */

#include "codelet-dft.h"

#ifdef HAVE_FMA

/* Generated by: ../../../genfft/gen_notw_c -fma -reorder-insns -schedule-for-pipeline -simd -compact -variables 4 -pipeline-latency 8 -sign 1 -n 7 -name n1bv_7 -include n1b.h */

/*
 * This function contains 30 FP additions, 24 FP multiplications,
 * (or, 9 additions, 3 multiplications, 21 fused multiply/add),
 * 37 stack variables, and 14 memory accesses
 */
/*
 * Generator Id's : 
 * $Id: algsimp.ml,v 1.9 2006-02-12 23:34:12 athena Exp $
 * $Id: fft.ml,v 1.4 2006-01-05 03:04:27 stevenj Exp $
 * $Id: gen_notw_c.ml,v 1.17 2006-02-12 23:34:12 athena Exp $
 */

#include "n1b.h"

static void n1bv_7(const R *ri, const R *ii, R *ro, R *io, stride is, stride os, INT v, INT ivs, INT ovs)
{
     DVK(KP900968867, +0.900968867902419126236102319507445051165919162);
     DVK(KP692021471, +0.692021471630095869627814897002069140197260599);
     DVK(KP801937735, +0.801937735804838252472204639014890102331838324);
     DVK(KP974927912, +0.974927912181823607018131682993931217232785801);
     DVK(KP356895867, +0.356895867892209443894399510021300583399127187);
     DVK(KP554958132, +0.554958132087371191422194871006410481067288862);
     INT i;
     const R *xi;
     R *xo;
     xi = ii;
     xo = io;
     for (i = v; i > 0; i = i - VL, xi = xi + (VL * ivs), xo = xo + (VL * ovs), MAKE_VOLATILE_STRIDE(is), MAKE_VOLATILE_STRIDE(os)) {
	  V T1, T2, T3, T8, T9, T5, T6;
	  T1 = LD(&(xi[0]), ivs, &(xi[0]));
	  T2 = LD(&(xi[WS(is, 1)]), ivs, &(xi[WS(is, 1)]));
	  T3 = LD(&(xi[WS(is, 6)]), ivs, &(xi[0]));
	  T8 = LD(&(xi[WS(is, 3)]), ivs, &(xi[WS(is, 1)]));
	  T9 = LD(&(xi[WS(is, 4)]), ivs, &(xi[0]));
	  T5 = LD(&(xi[WS(is, 2)]), ivs, &(xi[0]));
	  T6 = LD(&(xi[WS(is, 5)]), ivs, &(xi[WS(is, 1)]));
	  {
	       V Tg, T4, Te, Ta, Tf, T7;
	       Tg = VSUB(T2, T3);
	       T4 = VADD(T2, T3);
	       Te = VSUB(T8, T9);
	       Ta = VADD(T8, T9);
	       Tf = VSUB(T5, T6);
	       T7 = VADD(T5, T6);
	       {
		    V Tr, Tj, Tm, Th, To, Tb;
		    Tr = VFMA(LDK(KP554958132), Te, Tg);
		    Tj = VFNMS(LDK(KP356895867), T4, Ta);
		    Tm = VFMA(LDK(KP554958132), Tf, Te);
		    Th = VFNMS(LDK(KP554958132), Tg, Tf);
		    ST(&(xo[0]), VADD(T1, VADD(T4, VADD(T7, Ta))), ovs, &(xo[0]));
		    To = VFNMS(LDK(KP356895867), T7, T4);
		    Tb = VFNMS(LDK(KP356895867), Ta, T7);
		    {
			 V Ts, Tk, Tn, Ti;
			 Ts = VMUL(LDK(KP974927912), VFMA(LDK(KP801937735), Tr, Tf));
			 Tk = VFNMS(LDK(KP692021471), Tj, T7);
			 Tn = VMUL(LDK(KP974927912), VFNMS(LDK(KP801937735), Tm, Tg));
			 Ti = VMUL(LDK(KP974927912), VFNMS(LDK(KP801937735), Th, Te));
			 {
			      V Tp, Tc, Tl, Tq, Td;
			      Tp = VFNMS(LDK(KP692021471), To, Ta);
			      Tc = VFNMS(LDK(KP692021471), Tb, T4);
			      Tl = VFNMS(LDK(KP900968867), Tk, T1);
			      Tq = VFNMS(LDK(KP900968867), Tp, T1);
			      Td = VFNMS(LDK(KP900968867), Tc, T1);
			      ST(&(xo[WS(os, 5)]), VFNMSI(Tn, Tl), ovs, &(xo[WS(os, 1)]));
			      ST(&(xo[WS(os, 2)]), VFMAI(Tn, Tl), ovs, &(xo[0]));
			      ST(&(xo[WS(os, 6)]), VFNMSI(Ts, Tq), ovs, &(xo[0]));
			      ST(&(xo[WS(os, 1)]), VFMAI(Ts, Tq), ovs, &(xo[WS(os, 1)]));
			      ST(&(xo[WS(os, 4)]), VFNMSI(Ti, Td), ovs, &(xo[0]));
			      ST(&(xo[WS(os, 3)]), VFMAI(Ti, Td), ovs, &(xo[WS(os, 1)]));
			 }
		    }
	       }
	  }
     }
}

static const kdft_desc desc = { 7, "n1bv_7", {9, 3, 21, 0}, &GENUS, 0, 0, 0, 0 };
void X(codelet_n1bv_7) (planner *p) {
     X(kdft_register) (p, n1bv_7, &desc);
}

#else				/* HAVE_FMA */

/* Generated by: ../../../genfft/gen_notw_c -simd -compact -variables 4 -pipeline-latency 8 -sign 1 -n 7 -name n1bv_7 -include n1b.h */

/*
 * This function contains 30 FP additions, 18 FP multiplications,
 * (or, 18 additions, 6 multiplications, 12 fused multiply/add),
 * 24 stack variables, and 14 memory accesses
 */
/*
 * Generator Id's : 
 * $Id: algsimp.ml,v 1.9 2006-02-12 23:34:12 athena Exp $
 * $Id: fft.ml,v 1.4 2006-01-05 03:04:27 stevenj Exp $
 * $Id: gen_notw_c.ml,v 1.17 2006-02-12 23:34:12 athena Exp $
 */

#include "n1b.h"

static void n1bv_7(const R *ri, const R *ii, R *ro, R *io, stride is, stride os, INT v, INT ivs, INT ovs)
{
     DVK(KP222520933, +0.222520933956314404288902564496794759466355569);
     DVK(KP900968867, +0.900968867902419126236102319507445051165919162);
     DVK(KP623489801, +0.623489801858733530525004884004239810632274731);
     DVK(KP433883739, +0.433883739117558120475768332848358754609990728);
     DVK(KP781831482, +0.781831482468029808708444526674057750232334519);
     DVK(KP974927912, +0.974927912181823607018131682993931217232785801);
     INT i;
     const R *xi;
     R *xo;
     xi = ii;
     xo = io;
     for (i = v; i > 0; i = i - VL, xi = xi + (VL * ivs), xo = xo + (VL * ovs), MAKE_VOLATILE_STRIDE(is), MAKE_VOLATILE_STRIDE(os)) {
	  V Tb, T9, Tc, T3, Te, T6, Td, T7, T8, Ti, Tj;
	  Tb = LD(&(xi[0]), ivs, &(xi[0]));
	  T7 = LD(&(xi[WS(is, 2)]), ivs, &(xi[0]));
	  T8 = LD(&(xi[WS(is, 5)]), ivs, &(xi[WS(is, 1)]));
	  T9 = VSUB(T7, T8);
	  Tc = VADD(T7, T8);
	  {
	       V T1, T2, T4, T5;
	       T1 = LD(&(xi[WS(is, 1)]), ivs, &(xi[WS(is, 1)]));
	       T2 = LD(&(xi[WS(is, 6)]), ivs, &(xi[0]));
	       T3 = VSUB(T1, T2);
	       Te = VADD(T1, T2);
	       T4 = LD(&(xi[WS(is, 3)]), ivs, &(xi[WS(is, 1)]));
	       T5 = LD(&(xi[WS(is, 4)]), ivs, &(xi[0]));
	       T6 = VSUB(T4, T5);
	       Td = VADD(T4, T5);
	  }
	  ST(&(xo[0]), VADD(Tb, VADD(Te, VADD(Tc, Td))), ovs, &(xo[0]));
	  Ti = VBYI(VFNMS(LDK(KP781831482), T6, VFNMS(LDK(KP433883739), T9, VMUL(LDK(KP974927912), T3))));
	  Tj = VFMA(LDK(KP623489801), Td, VFNMS(LDK(KP900968867), Tc, VFNMS(LDK(KP222520933), Te, Tb)));
	  ST(&(xo[WS(os, 2)]), VADD(Ti, Tj), ovs, &(xo[0]));
	  ST(&(xo[WS(os, 5)]), VSUB(Tj, Ti), ovs, &(xo[WS(os, 1)]));
	  {
	       V Ta, Tf, Tg, Th;
	       Ta = VBYI(VFMA(LDK(KP433883739), T3, VFNMS(LDK(KP781831482), T9, VMUL(LDK(KP974927912), T6))));
	       Tf = VFMA(LDK(KP623489801), Tc, VFNMS(LDK(KP222520933), Td, VFNMS(LDK(KP900968867), Te, Tb)));
	       ST(&(xo[WS(os, 3)]), VADD(Ta, Tf), ovs, &(xo[WS(os, 1)]));
	       ST(&(xo[WS(os, 4)]), VSUB(Tf, Ta), ovs, &(xo[0]));
	       Tg = VBYI(VFMA(LDK(KP781831482), T3, VFMA(LDK(KP974927912), T9, VMUL(LDK(KP433883739), T6))));
	       Th = VFMA(LDK(KP623489801), Te, VFNMS(LDK(KP900968867), Td, VFNMS(LDK(KP222520933), Tc, Tb)));
	       ST(&(xo[WS(os, 1)]), VADD(Tg, Th), ovs, &(xo[WS(os, 1)]));
	       ST(&(xo[WS(os, 6)]), VSUB(Th, Tg), ovs, &(xo[0]));
	  }
     }
}

static const kdft_desc desc = { 7, "n1bv_7", {18, 6, 12, 0}, &GENUS, 0, 0, 0, 0 };
void X(codelet_n1bv_7) (planner *p) {
     X(kdft_register) (p, n1bv_7, &desc);
}

#endif				/* HAVE_FMA */
