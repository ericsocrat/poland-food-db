interface SourceCitationProps {
  /** Author(s) or organization name. */
  readonly author: string;
  /** Title of the source document. */
  readonly title: string;
  /** URL to the source. */
  readonly url?: string;
  /** Year of publication or access. */
  readonly year?: string | number;
  /** Optional additional classes. */
  readonly className?: string;
}

/**
 * Formatted citation block for scientific/regulatory sources.
 * Renders as a compact, accessible reference.
 */
export function SourceCitation({
  author,
  title,
  url,
  year,
  className = "",
}: SourceCitationProps) {
  return (
    <cite
      className={`block text-sm not-italic text-foreground-secondary ${className}`}
    >
      <span className="font-medium">{author}</span>
      {year ? ` (${year})` : ""}. <em>{title}</em>.
      {url ? (
        <>
          {" "}
          <a
            href={url}
            target="_blank"
            rel="noopener noreferrer"
            className="text-brand underline hover:text-brand-hover"
          >
            Link ↗
          </a>
        </>
      ) : null}
    </cite>
  );
}
