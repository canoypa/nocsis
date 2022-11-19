import { Component, PropsWithChildren } from "react";

class RootErrorBoundary extends Component<PropsWithChildren> {
  state: { hasError: boolean };

  constructor(props: PropsWithChildren) {
    super(props);

    this.state = { hasError: false };
  }

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch() {
    // reload page after 10s
    setTimeout(() => window.location.reload(), 10000);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{ color: "red" }}>
          <h1>ERROR!</h1>
          <p>Page will reload after 10 seconds.</p>
        </div>
      );
    }

    return this.props.children;
  }
}
export default RootErrorBoundary;
