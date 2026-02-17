"use client";

import { notFound } from "next/navigation";
import {
  Button,
  IconButton,
  Input,
  Select,
  Textarea,
  Toggle,
  Checkbox,
  Card,
  Badge,
  Chip,
  ProgressBar,
  Tooltip,
  Alert,
  ScoreBadge,
  NutriScoreBadge,
  NovaBadge,
  ConfidenceBadge,
  NutrientTrafficLight,
  AllergenBadge,
} from "@/components/common";
import { useState } from "react";

// Only accessible in development
if (process.env.NODE_ENV === "production") {
  // eslint-disable-next-line react-hooks/rules-of-hooks -- build-time guard
}

function Section({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section className="space-y-4">
      <h2 className="text-xl font-semibold text-foreground border-b border-border pb-2">
        {title}
      </h2>
      {children}
    </section>
  );
}

function Row({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="space-y-1">
      <p className="text-sm text-foreground-secondary font-medium">{label}</p>
      <div className="flex flex-wrap items-center gap-3">{children}</div>
    </div>
  );
}

export default function DevComponentsPage() {
  if (process.env.NODE_ENV === "production") {
    notFound();
  }

  const [toggle1, setToggle1] = useState(false);
  const [toggle2, setToggle2] = useState(true);
  const [check1, setCheck1] = useState(false);

  return (
    <div className="min-h-screen bg-surface p-8 space-y-12 max-w-5xl mx-auto">
      <header>
        <h1 className="text-3xl font-bold text-foreground">
          Component Library
        </h1>
        <p className="text-foreground-secondary mt-1">
          Development-only showcase — all components from{" "}
          <code className="text-sm bg-surface-muted px-1 rounded">
            @/components/common
          </code>
        </p>
      </header>

      {/* ── Buttons ── */}
      <Section title="Button">
        <Row label="Variants">
          <Button variant="primary">Primary</Button>
          <Button variant="secondary">Secondary</Button>
          <Button variant="ghost">Ghost</Button>
          <Button variant="danger">Danger</Button>
        </Row>
        <Row label="Sizes">
          <Button size="sm">Small</Button>
          <Button size="md">Medium</Button>
          <Button size="lg">Large</Button>
        </Row>
        <Row label="States">
          <Button loading>Loading</Button>
          <Button disabled>Disabled</Button>
          <Button fullWidth>Full Width</Button>
        </Row>
      </Section>

      {/* ── IconButton ── */}
      <Section title="IconButton">
        <Row label="Variants">
          <IconButton icon={<span>✏️</span>} label="Edit" variant="primary" />
          <IconButton icon={<span>🗑️</span>} label="Delete" variant="danger" />
          <IconButton icon={<span>⚙️</span>} label="Settings" variant="ghost" />
          <IconButton icon={<span>📋</span>} label="Copy" variant="secondary" />
        </Row>
        <Row label="Sizes">
          <IconButton icon={<span>✏️</span>} label="Small" size="sm" />
          <IconButton icon={<span>✏️</span>} label="Medium" size="md" />
          <IconButton icon={<span>✏️</span>} label="Large" size="lg" />
        </Row>
      </Section>

      {/* ── Input ── */}
      <Section title="Input">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 max-w-2xl">
          <Input label="Default" placeholder="Type here…" />
          <Input
            label="With error"
            error="This field is required"
            defaultValue="bad"
          />
          <Input label="With hint" hint="Max 100 characters" />
          <Input
            label="With icon"
            icon={<span>🔍</span>}
            placeholder="Search…"
          />
          <Input label="Disabled" disabled defaultValue="Cannot edit" />
          <Input label="Small" size="sm" placeholder="Small input" />
        </div>
      </Section>

      {/* ── Select ── */}
      <Section title="Select">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 max-w-2xl">
          <Select
            label="Category"
            placeholder="Choose…"
            options={[
              { value: "chips", label: "Chips" },
              { value: "drinks", label: "Drinks" },
              { value: "cereals", label: "Cereals" },
            ]}
          />
          <Select
            label="With error"
            error="Required"
            options={[{ value: "a", label: "Option A" }]}
          />
        </div>
      </Section>

      {/* ── Textarea ── */}
      <Section title="Textarea">
        <div className="max-w-md">
          <Textarea
            label="Notes"
            hint="Optional notes"
            showCount
            currentLength={42}
            maxLength={500}
            defaultValue="Example text content for the textarea component."
          />
        </div>
      </Section>

      {/* ── Toggle ── */}
      <Section title="Toggle">
        <Row label="States">
          <Toggle label="Off" checked={toggle1} onChange={setToggle1} />
          <Toggle label="On" checked={toggle2} onChange={setToggle2} />
          <Toggle
            label="Disabled"
            checked={false}
            onChange={() => {}}
            disabled
          />
          <Toggle label="Small" checked={true} onChange={() => {}} size="sm" />
        </Row>
      </Section>

      {/* ── Checkbox ── */}
      <Section title="Checkbox">
        <Row label="States">
          <Checkbox
            label="Default"
            checked={check1}
            onChange={() => setCheck1(!check1)}
          />
          <Checkbox label="Checked" checked={true} onChange={() => {}} />
          <Checkbox label="Indeterminate" indeterminate onChange={() => {}} />
          <Checkbox label="Disabled" disabled onChange={() => {}} />
        </Row>
      </Section>

      {/* ── Card ── */}
      <Section title="Card">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Card variant="default">
            <p className="font-medium">Default</p>
            <p className="text-sm text-foreground-secondary">
              Standard card with border
            </p>
          </Card>
          <Card variant="elevated">
            <p className="font-medium">Elevated</p>
            <p className="text-sm text-foreground-secondary">
              Card with shadow
            </p>
          </Card>
          <Card variant="outlined">
            <p className="font-medium">Outlined</p>
            <p className="text-sm text-foreground-secondary">
              Stronger border, no shadow
            </p>
          </Card>
        </div>
      </Section>

      {/* ── Badge ── */}
      <Section title="Badge">
        <Row label="Variants">
          <Badge variant="info">Info</Badge>
          <Badge variant="success">Success</Badge>
          <Badge variant="warning">Warning</Badge>
          <Badge variant="error">Error</Badge>
          <Badge variant="neutral">Neutral</Badge>
        </Row>
        <Row label="With dot">
          <Badge variant="success" dot>
            Active
          </Badge>
          <Badge variant="error" dot>
            Offline
          </Badge>
        </Row>
        <Row label="Sizes">
          <Badge size="sm">Small</Badge>
          <Badge size="md">Medium</Badge>
        </Row>
      </Section>

      {/* ── Chip ── */}
      <Section title="Chip">
        <Row label="Variants">
          <Chip variant="default">Default</Chip>
          <Chip variant="primary">Primary</Chip>
          <Chip variant="success">Success</Chip>
          <Chip variant="warning">Warning</Chip>
          <Chip variant="error">Error</Chip>
        </Row>
        <Row label="Interactive">
          <Chip interactive onClick={() => {}}>
            Clickable
          </Chip>
          <Chip onRemove={() => {}}>Removable</Chip>
        </Row>
      </Section>

      {/* ── ProgressBar ── */}
      <Section title="ProgressBar">
        <div className="space-y-3 max-w-md">
          <ProgressBar value={25} variant="brand" showLabel />
          <ProgressBar value={50} variant="success" showLabel />
          <ProgressBar value={75} variant="warning" showLabel />
          <ProgressBar value={90} variant="error" showLabel />
          <ProgressBar value={60} variant="score" size="lg" showLabel />
        </div>
      </Section>

      {/* ── Tooltip ── */}
      <Section title="Tooltip">
        <Row label="Placements">
          <Tooltip content="Top tooltip" side="top">
            <Button variant="secondary" size="sm">
              Top
            </Button>
          </Tooltip>
          <Tooltip content="Right tooltip" side="right">
            <Button variant="secondary" size="sm">
              Right
            </Button>
          </Tooltip>
          <Tooltip content="Bottom tooltip" side="bottom">
            <Button variant="secondary" size="sm">
              Bottom
            </Button>
          </Tooltip>
          <Tooltip content="Left tooltip" side="left">
            <Button variant="secondary" size="sm">
              Left
            </Button>
          </Tooltip>
        </Row>
      </Section>

      {/* ── Alert ── */}
      <Section title="Alert">
        <div className="space-y-3 max-w-xl">
          <Alert variant="info" title="Information">
            This is an informational alert.
          </Alert>
          <Alert variant="success" title="Success">
            Operation completed successfully.
          </Alert>
          <Alert variant="warning" title="Warning">
            Please review before proceeding.
          </Alert>
          <Alert variant="error" title="Error" dismissible>
            Something went wrong. Click ✕ to dismiss.
          </Alert>
        </div>
      </Section>

      {/* ── ScoreBadge ── */}
      <Section title="ScoreBadge">
        <Row label="Score bands (1–100)">
          <ScoreBadge score={10} showLabel />
          <ScoreBadge score={30} showLabel />
          <ScoreBadge score={50} showLabel />
          <ScoreBadge score={70} showLabel />
          <ScoreBadge score={90} showLabel />
          <ScoreBadge score={null} />
        </Row>
        <Row label="Sizes">
          <ScoreBadge score={42} size="sm" />
          <ScoreBadge score={42} size="md" />
          <ScoreBadge score={42} size="lg" />
        </Row>
      </Section>

      {/* ── NutriScoreBadge ── */}
      <Section title="NutriScoreBadge">
        <Row label="Grades A–E">
          <NutriScoreBadge grade="A" />
          <NutriScoreBadge grade="B" />
          <NutriScoreBadge grade="C" />
          <NutriScoreBadge grade="D" />
          <NutriScoreBadge grade="E" />
          <NutriScoreBadge grade={null} />
        </Row>
        <Row label="Sizes">
          <NutriScoreBadge grade="B" size="sm" />
          <NutriScoreBadge grade="B" size="md" />
          <NutriScoreBadge grade="B" size="lg" />
        </Row>
      </Section>

      {/* ── NovaBadge ── */}
      <Section title="NovaBadge">
        <Row label="Groups 1–4">
          <NovaBadge group={1} showLabel />
          <NovaBadge group={2} showLabel />
          <NovaBadge group={3} showLabel />
          <NovaBadge group={4} showLabel />
          <NovaBadge group={null} />
        </Row>
      </Section>

      {/* ── ConfidenceBadge ── */}
      <Section title="ConfidenceBadge">
        <Row label="Levels">
          <ConfidenceBadge level="high" percentage={95} />
          <ConfidenceBadge level="medium" percentage={65} />
          <ConfidenceBadge level="low" percentage={30} />
          <ConfidenceBadge level={null} />
        </Row>
      </Section>

      {/* ── NutrientTrafficLight ── */}
      <Section title="NutrientTrafficLight">
        <Row label="Per 100 g">
          <NutrientTrafficLight nutrient="fat" value={2.5} />
          <NutrientTrafficLight nutrient="saturates" value={8.0} />
          <NutrientTrafficLight nutrient="sugars" value={15.0} />
          <NutrientTrafficLight nutrient="salt" value={0.3} />
        </Row>
      </Section>

      {/* ── AllergenBadge ── */}
      <Section title="AllergenBadge">
        <Row label="Status">
          <AllergenBadge status="present" allergenName="Gluten" />
          <AllergenBadge status="traces" allergenName="Milk" />
          <AllergenBadge status="free" allergenName="Nuts" />
        </Row>
      </Section>
    </div>
  );
}
