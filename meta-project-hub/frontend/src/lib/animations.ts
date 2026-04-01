/**
 * Animation Components
 * Reusable Framer Motion components for consistent animations
 */

'use client';

import { motion } from 'framer-motion';
import { ReactNode } from 'react';

// Variants
export const fadeIn = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { duration: 0.4 } }
};

export const slideIn = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.4 } }
};

export const scaleIn = {
  hidden: { opacity: 0, scale: 0.9 },
  visible: { opacity: 1, scale: 1, transition: { duration: 0.3 } }
};

export const staggerContainer = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.05
    }
  }
};

export const slideUp = {
  hidden: { opacity: 0, y: 30 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.5, ease: 'easeOut' } }
};

export const slideDown = {
  hidden: { opacity: 0, y: -20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.4 } }
};

// Pulse animation for live indicators
export const pulse = {
  animate: {
    scale: [1, 1.1, 1],
    opacity: [1, 0.8, 1],
    transition: {
      duration: 2,
      repeat: Infinity,
      ease: 'easeInOut'
    }
  }
};

// Progress bar animation
export const progressBar = {
  hidden: { width: 0 },
  visible: (width: number) => ({
    width: `${width}%`,
    transition: { duration: 1, ease: 'easeOut' }
  })
};

// Hover lift effect
export const hoverLift = {
  hover: {
    y: -4,
    scale: 1.02,
    transition: { duration: 0.2 }
  },
  tap: {
    scale: 0.98
  }
};

// Container component with stagger
interface AnimateContainerProps {
  children: ReactNode;
  className?: string;
  delay?: number;
}

export function AnimateContainer({ children, className = '', delay = 0 }: AnimateContainerProps) {
  return (
    <motion.div
      initial="hidden"
      animate="visible"
      variants={staggerContainer}
      className={className}
      transition={{ delay }}
    >
      {children}
    </motion.div>
  );
}

// Fade In component
interface FadeInProps {
  children: ReactNode;
  className?: string;
  delay?: number;
  duration?: number;
}

export function FadeIn({ children, className = '', delay = 0, duration = 0.4 }: FadeInProps) {
  return (
    <motion.div
      initial="hidden"
      animate="visible"
      variants={{
        hidden: { opacity: 0 },
        visible: { opacity: 1, transition: { duration, delay } }
      }}
      className={className}
    >
      {children}
    </motion.div>
  );
}

// Slide In component
interface SlideInProps {
  children: ReactNode;
  className?: string;
  delay?: number;
  direction?: 'up' | 'down' | 'left' | 'right';
}

export function SlideIn({ children, className = '', delay = 0, direction = 'up' }: SlideInProps) {
  const directions = {
    up: { y: 30, x: 0 },
    down: { y: -30, x: 0 },
    left: { x: 30, y: 0 },
    right: { x: -30, y: 0 }
  };

  return (
    <motion.div
      initial="hidden"
      animate="visible"
      variants={{
        hidden: { opacity: 0, ...directions[direction] },
        visible: { 
          opacity: 1, 
          x: 0, 
          y: 0, 
          transition: { duration: 0.5, delay, ease: 'easeOut' } 
        }
      }}
      className={className}
    >
      {children}
    </motion.div>
  );
}

// Scale In component
interface ScaleInProps {
  children: ReactNode;
  className?: string;
  delay?: number;
}

export function ScaleIn({ children, className = '', delay = 0 }: ScaleInProps) {
  return (
    <motion.div
      initial="hidden"
      animate="visible"
      variants={{
        hidden: { opacity: 0, scale: 0.9 },
        visible: { 
          opacity: 1, 
          scale: 1, 
          transition: { duration: 0.3, delay, ease: 'easeOut' } 
        }
      }}
      className={className}
    >
      {children}
    </motion.div>
  );
}

// Hover Lift component (for cards/buttons)
interface HoverLiftProps {
  children: ReactNode;
  className?: string;
  onClick?: () => void;
}

export function HoverLift({ children, className = '', onClick }: HoverLiftProps) {
  return (
    <motion.div
      variants={hoverLift}
      whileHover="hover"
      whileTap="tap"
      className={className}
      onClick={onClick}
    >
      {children}
    </motion.div>
  );
}

// Pulse component (for live indicators)
interface PulseProps {
  children: ReactNode;
  className?: string;
}

export function Pulse({ children, className = '' }: PulseProps) {
  return (
    <motion.div
      variants={pulse}
      animate="animate"
      className={className}
    >
      {children}
    </motion.div>
  );
}

// Progress Bar component with animation
interface AnimatedProgressBarProps {
  progress: number;
  className?: string;
  color?: string;
}

export function AnimatedProgressBar({ progress, className = '', color = 'from-amber-500 to-orange-500' }: AnimatedProgressBarProps) {
  return (
    <motion.div
      initial={{ width: 0 }}
      animate={{ width: `${progress}%` }}
      transition={{ duration: 1, ease: 'easeOut', delay: 0.2 }}
      className={`h-full bg-gradient-to-r ${color}`}
      style={{ width: `${progress}%` }}
    />
  );
}

// Counter animation component
interface AnimatedCounterProps {
  value: number;
  className?: string;
  duration?: number;
}

export function AnimatedCounter({ value, className = '', duration = 1 }: AnimatedCounterProps) {
  return (
    <motion.span
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration }}
      className={className}
    >
      {value}
    </motion.span>
  );
}

// Page transition wrapper
interface PageTransitionProps {
  children: ReactNode;
}

export function PageTransition({ children }: PageTransitionProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      transition={{ duration: 0.4, ease: 'easeOut' }}
    >
      {children}
    </motion.div>
  );
}

// Grid stagger for panel grids
export const gridStagger = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.08,
      delayChildren: 0.2
    }
  }
};

export const gridItem = {
  hidden: { opacity: 0, y: 30 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.5,
      ease: 'easeOut'
    }
  }
};
